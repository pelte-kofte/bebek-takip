#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def convert_png_to_webp(
    source: Path,
    *,
    quality: int,
    method: int,
    delete_source: bool,
) -> None:
    target = source.with_suffix(".webp")

    with Image.open(source) as image:
        save_kwargs = {
            "format": "WEBP",
            "quality": quality,
            "method": method,
        }

        if image.mode not in {"RGB", "RGBA"}:
            image = image.convert("RGBA" if "A" in image.getbands() else "RGB")

        image.save(target, **save_kwargs)

    if delete_source:
        source.unlink()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Convert daily tip PNG assets in a folder to WebP.",
    )
    parser.add_argument(
        "asset_dir",
        nargs="?",
        default="assets/illustrations/tips",
        help="Directory containing daily tip PNG assets.",
    )
    parser.add_argument(
        "--quality",
        type=int,
        default=80,
        help="WebP lossy quality (default: 80).",
    )
    parser.add_argument(
        "--method",
        type=int,
        default=6,
        help="WebP encoder method (default: 6).",
    )
    parser.add_argument(
        "--keep-png",
        action="store_true",
        help="Keep source PNG files after conversion.",
    )
    args = parser.parse_args()

    asset_dir = Path(args.asset_dir)
    png_files = sorted(asset_dir.glob("*.png"))

    if not png_files:
        raise SystemExit(f"No PNG files found in {asset_dir}")

    for png_file in png_files:
        convert_png_to_webp(
            png_file,
            quality=args.quality,
            method=args.method,
            delete_source=not args.keep_png,
        )
        print(f"converted {png_file} -> {png_file.with_suffix('.webp')}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
