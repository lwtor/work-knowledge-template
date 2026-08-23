#!/usr/bin/env python3
"""Encrypted incremental transfer for the personal knowledge data directories.

This tool deliberately excludes the framework files. It transfers only:
Knowledge, Projects, Daily, Inbox, and Attachments.
Encryption is delegated to the age command-line tool.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import sys
import tarfile
import tempfile
from datetime import datetime, timezone


FORMAT_VERSION = 1
DATA_ROOTS = ("Knowledge", "Projects", "Daily", "Inbox", "Attachments")
PLACEHOLDER_FILES = {f"{name}/README.md" for name in DATA_ROOTS}
STATE_DIR = ".kb-transfer"
STATE_FILE = "manifest.json"


def fail(message: str) -> "NoReturn":
    print(f"错误：{message}", file=sys.stderr)
    raise SystemExit(1)


def age_path() -> str:
    path = shutil.which("age")
    if not path:
        fail(
            "没有找到 age。请先安装 age，再重试。macOS 可执行 `brew install age`；"
            "Windows 请从 https://github.com/FiloSottile/age/releases 安装并确保 age 在 PATH 中。"
        )
    return path


def vault_root(value: str | None) -> Path:
    root = Path(value).expanduser().resolve() if value else Path(__file__).resolve().parents[1]
    if not root.is_dir():
        fail(f"知识库目录不存在：{root}")
    return root


def rel_key(path: Path, root: Path) -> str:
    return path.relative_to(root).as_posix()


def data_files(root: Path) -> dict[str, dict[str, int | str]]:
    result: dict[str, dict[str, int | str]] = {}
    for name in DATA_ROOTS:
        directory = root / name
        if not directory.is_dir():
            continue
        for path in directory.rglob("*"):
            if not path.is_file() or path.is_symlink():
                continue
            relative = rel_key(path, root)
            if relative in PLACEHOLDER_FILES:
                continue
            digest = hashlib.sha256(path.read_bytes()).hexdigest()
            result[relative] = {"sha256": digest, "size": path.stat().st_size}
    return dict(sorted(result.items()))


def json_bytes(value: object) -> bytes:
    return (json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2) + "\n").encode("utf-8")


def manifest_hash(manifest: dict[str, dict[str, int | str]]) -> str:
    return hashlib.sha256(json_bytes(manifest)).hexdigest()


def read_state(root: Path) -> dict[str, dict[str, int | str]]:
    path = root / STATE_DIR / STATE_FILE
    if not path.exists():
        return {}
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"无法读取增量状态 {path}: {exc}")
    if not isinstance(value, dict):
        fail(f"增量状态格式错误：{path}")
    return value


def write_state(root: Path, manifest: dict[str, dict[str, int | str]]) -> None:
    directory = root / STATE_DIR
    directory.mkdir(parents=True, exist_ok=True)
    temporary = directory / f"{STATE_FILE}.tmp"
    temporary.write_bytes(json_bytes(manifest))
    os.replace(temporary, directory / STATE_FILE)


def safe_relative(value: str) -> Path:
    candidate = PurePosixPath(value)
    if candidate.is_absolute() or ".." in candidate.parts or not candidate.parts:
        fail(f"加密包包含不安全路径：{value}")
    return Path(*candidate.parts)


def add_bytes(archive: tarfile.TarFile, name: str, content: bytes) -> None:
    info = tarfile.TarInfo(name)
    info.size = len(content)
    info.mtime = 0
    archive.addfile(info, io.BytesIO(content))


def run_age_encrypt(age: str, output: Path, root: Path, changed: list[str], metadata: dict, manifest: dict, deleted: list[str], recipient_file: str | None) -> None:
    command = [age, "-R", recipient_file, "-o", str(output)] if recipient_file else [age, "-p", "-o", str(output)]
    process = subprocess.Popen(command, stdin=subprocess.PIPE)
    assert process.stdin is not None
    try:
        with tarfile.open(fileobj=process.stdin, mode="w|gz") as archive:
            add_bytes(archive, "metadata.json", json_bytes(metadata))
            add_bytes(archive, "manifest.json", json_bytes(manifest))
            add_bytes(archive, "deleted.json", json_bytes(deleted))
            for relative in changed:
                archive.add(root / safe_relative(relative), arcname=f"files/{relative}")
        process.stdin.close()
    except Exception:
        process.kill()
        process.wait()
        output.unlink(missing_ok=True)
        raise
    if process.wait() != 0:
        output.unlink(missing_ok=True)
        fail("age 加密失败，未生成有效传输包。")


def read_decrypted_package(age: str, package: Path, identity_file: str | None) -> tuple[dict, dict, list[str]]:
    if not package.is_file():
        fail(f"传输包不存在：{package}")
    command = [age, "-d", "-i", identity_file, str(package)] if identity_file else [age, "-d", str(package)]
    process = subprocess.Popen(command, stdout=subprocess.PIPE)
    assert process.stdout is not None
    metadata: dict | None = None
    manifest: dict | None = None
    deleted: list[str] | None = None
    try:
        with tarfile.open(fileobj=process.stdout, mode="r|gz") as archive:
            for member in archive:
                if member.name == "metadata.json":
                    metadata = json.loads(archive.extractfile(member).read().decode("utf-8"))
                elif member.name == "manifest.json":
                    manifest = json.loads(archive.extractfile(member).read().decode("utf-8"))
                elif member.name == "deleted.json":
                    deleted = json.loads(archive.extractfile(member).read().decode("utf-8"))
                elif member.name.startswith("files/"):
                    if not member.isfile():
                        fail(f"加密包中的文件项不是普通文件：{member.name}")
                    stream = archive.extractfile(member)
                    if stream:
                        while stream.read(1024 * 1024):
                            pass
        code = process.wait()
    except Exception:
        process.kill()
        process.wait()
        raise
    if code != 0:
        fail("age 解密失败，请检查密码或传输包是否损坏。")
    if not isinstance(metadata, dict) or not isinstance(manifest, dict) or not isinstance(deleted, list):
        fail("传输包缺少有效的元数据、清单或删除列表。")
    return metadata, manifest, deleted


def check_package_conflict(root: Path, metadata: dict) -> None:
    if metadata.get("format_version") != FORMAT_VERSION:
        fail(f"不支持的传输包版本：{metadata.get('format_version')}")
    current = data_files(root)
    current_hash = manifest_hash(current)
    expected = metadata.get("base_manifest_sha256", "")
    if current_hash != expected:
        fail(
            "检测到本地个人数据与传输包的基础版本不一致，已停止导入。"
            "请先同步另一台电脑的修改，或由你确认如何合并冲突。"
        )


def apply_package(age: str, package: Path, root: Path, manifest: dict, deleted: list[str], identity_file: str | None) -> None:
    command = [age, "-d", "-i", identity_file, str(package)] if identity_file else [age, "-d", str(package)]
    process = subprocess.Popen(command, stdout=subprocess.PIPE)
    assert process.stdout is not None
    try:
        with tarfile.open(fileobj=process.stdout, mode="r|gz") as archive:
            for member in archive:
                if not member.name.startswith("files/"):
                    continue
                relative = safe_relative(member.name[len("files/"):])
                destination = root / relative
                destination.parent.mkdir(parents=True, exist_ok=True)
                stream = archive.extractfile(member)
                if stream is None:
                    fail(f"无法读取传输包文件：{member.name}")
                temporary = destination.with_name(destination.name + ".kb-transfer.tmp")
                with temporary.open("wb") as output:
                    shutil.copyfileobj(stream, output)
                os.replace(temporary, destination)
            process.wait()
    except Exception:
        process.kill()
        process.wait()
        raise
    if process.returncode != 0:
        fail("导入过程中解密失败，个人数据未能完整应用。")
    for value in deleted:
        destination = root / safe_relative(value)
        if destination.exists():
            destination.unlink()
    write_state(root, manifest)


def command_doctor(args: argparse.Namespace) -> None:
    root = vault_root(args.vault)
    print(json.dumps({
        "vault": str(root),
        "python": sys.version.split()[0],
        "git": shutil.which("git") is not None,
        "age": shutil.which("age") is not None,
        "data_roots": list(DATA_ROOTS),
        "encryption": "age passphrase",
        "incremental_state": str(root / STATE_DIR / STATE_FILE),
    }, ensure_ascii=False, indent=2))


def command_export(args: argparse.Namespace) -> None:
    root = vault_root(args.vault)
    age = age_path()
    output = Path(args.out).expanduser().resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    previous = read_state(root)
    current = data_files(root)
    changed = [path for path, info in current.items() if previous.get(path) != info]
    deleted = sorted(set(previous) - set(current))
    if not changed and not deleted:
        print("没有检测到个人数据变化，没有生成传输包。")
        return
    metadata = {
        "format_version": FORMAT_VERSION,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "base_manifest_sha256": manifest_hash(previous),
        "target_manifest_sha256": manifest_hash(current),
        "changed_files": len(changed),
        "deleted_files": len(deleted),
    }
    run_age_encrypt(age, output, root, changed, metadata, current, deleted, args.recipient_file)
    write_state(root, current)
    print(json.dumps({
        "package": str(output),
        "changed_files": len(changed),
        "deleted_files": len(deleted),
        "encrypted": True,
        "next": "将 .age 文件安全带到另一台电脑后执行 import",
    }, ensure_ascii=False, indent=2))


def command_import(args: argparse.Namespace) -> None:
    root = vault_root(args.vault)
    age = age_path()
    package = Path(args.package).expanduser().resolve()
    metadata, manifest, deleted = read_decrypted_package(age, package, args.identity_file)
    check_package_conflict(root, metadata)
    apply_package(age, package, root, manifest, deleted, args.identity_file)
    print(json.dumps({
        "vault": str(root),
        "imported": True,
        "target_manifest_sha256": manifest_hash(manifest),
        "deleted_files": len(deleted),
        "next": "检查 Obsidian 内容并执行 git diff / git commit",
    }, ensure_ascii=False, indent=2))


def parser() -> argparse.ArgumentParser:
    command = argparse.ArgumentParser(description="加密、增量传输个人知识库数据。")
    command.add_argument("--vault", help="知识库路径；默认使用当前脚本所属知识库")
    sub = command.add_subparsers(dest="command", required=True)
    doctor = sub.add_parser("doctor", help="检查 Python、Git、age 和数据目录")
    doctor.add_argument("--vault", default=argparse.SUPPRESS, help="知识库路径")
    doctor.set_defaults(handler=command_doctor)
    export = sub.add_parser("export", help="生成加密增量传输包")
    export.add_argument("--vault", default=argparse.SUPPRESS, help="知识库路径")
    export.add_argument("--out", required=True, help="输出 .age 文件路径")
    export.add_argument("--recipient-file", help="可选：age 公钥文件；提供后不询问密码")
    export.set_defaults(handler=command_export)
    importing = sub.add_parser("import", help="导入加密增量传输包")
    importing.add_argument("--vault", default=argparse.SUPPRESS, help="知识库路径")
    importing.add_argument("--package", required=True, help=".age 传输包路径")
    importing.add_argument("--identity-file", help="可选：age 私钥文件；提供后不询问密码")
    importing.set_defaults(handler=command_import)
    return command


if __name__ == "__main__":
    arguments = parser().parse_args()
    try:
        arguments.handler(arguments)
    except KeyboardInterrupt:
        fail("操作已取消。")
