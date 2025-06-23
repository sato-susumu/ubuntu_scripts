#!/usr/bin/env python3
"""USB Power Monitor - デバイスの電流消費と規格を監視"""

import subprocess
import re
from dataclasses import dataclass
from typing import List, Optional, Tuple


@dataclass
class USBDevice:
    """USBデバイス情報"""
    bus: str
    device: str
    name: str
    power_ma: int
    usb_version: str
    is_hub: bool = False


def run_command(cmd: str) -> str:
    """コマンドを実行して結果を返す"""
    try:
        result = subprocess.run(cmd.split(), capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError:
        return ""


def get_usb_devices() -> List[Tuple[str, str, str]]:
    """lsusbでデバイス一覧を取得"""
    output = run_command("lsusb")
    devices = []
    
    for line in output.strip().split('\n'):
        if not line:
            continue
        parts = line.split()
        if len(parts) >= 6:
            bus = parts[1]
            device = parts[3].rstrip(':')
            name = ' '.join(parts[6:])
            devices.append((bus, device, name))
    
    return devices


def get_power_info(bus: str, device: str) -> Optional[int]:
    """デバイスの消費電流を取得（mA）"""
    cmd = f"sudo lsusb -v -s {bus}:{device}"
    output = run_command(cmd)
    
    match = re.search(r'MaxPower\s+(\d+)mA', output)
    return int(match.group(1)) if match else None


def get_usb_version(bus: str, device: str) -> str:
    """USBバージョンを判定"""
    cmd = f"sudo lsusb -v -s {bus}:{device}"
    output = run_command(cmd)
    
    if re.search(r'bcdUSB\s+3\.', output):
        return "USB 3.x"
    elif re.search(r'bcdUSB\s+2\.', output):
        return "USB 2.0"
    elif re.search(r'bcdUSB\s+1\.', output):
        return "USB 1.x"
    else:
        return "Unknown"


def is_hub_device(name: str) -> bool:
    """ハブデバイスかどうか判定"""
    return 'hub' in name.lower() or 'root hub' in name.lower()


def get_compatibility_status(power_ma: int, usb_version: str, is_hub: bool) -> str:
    """電流とUSB規格の適合性をチェック"""
    if is_hub or power_ma == 0:
        return "セルフパワー"
    
    if power_ma > 900:
        return "⚠️ USB-C推奨"
    elif power_ma > 500:
        if usb_version == "USB 2.0":
            return "❌ 規格不適合"
        else:
            return "✅ 適合"
    else:
        return "✅ 適合"


def collect_usb_devices() -> List[USBDevice]:
    """全USBデバイス情報を収集"""
    devices = []
    
    for bus, device, name in get_usb_devices():
        is_hub = is_hub_device(name)
        power_ma = get_power_info(bus, device) or 0
        
        # ハブの場合はUSBバージョン取得をスキップして高速化
        if is_hub:
            usb_version = "Hub"
        else:
            usb_version = get_usb_version(bus, device)
        
        devices.append(USBDevice(
            bus=bus,
            device=device,
            name=name,
            power_ma=power_ma,
            usb_version=usb_version,
            is_hub=is_hub
        ))
    
    return devices


def print_header() -> None:
    """ヘッダー情報を表示"""
    print("=" * 50)
    print("  USB Power Monitor")
    print("=" * 50)
    print()
    print("📊 USB規格の電流制限:")
    print("  USB 2.0:     500mA")
    print("  USB 3.0/3.1: 900mA")
    print("  USB-C PD:    5000mA (5A)")
    print()


def print_device_table(devices: List[USBDevice]) -> None:
    """デバイス一覧テーブルを表示"""
    print("🔌 接続デバイスと消費電流・規格:")
    print("-" * 80)
    print(f"{'デバイス名':<40} {'消費電流':>8} {'USB規格':>10} {'備考'}")
    print("-" * 80)
    
    for device in devices:
        # デバイス名を40文字に制限
        short_name = device.name[:37] + "..." if len(device.name) > 40 else device.name
        power_str = f"{device.power_ma}mA" if device.power_ma > 0 else "0mA"
        status = get_compatibility_status(device.power_ma, device.usb_version, device.is_hub)
        
        print(f"{short_name:<40} {power_str:>8} {device.usb_version:>10} {status}")
    
    print()


def print_summary(devices: List[USBDevice]) -> None:
    """使用状況サマリーを表示"""
    total_current = sum(d.power_ma for d in devices if not d.is_hub)
    high_power_count = sum(1 for d in devices if not d.is_hub and d.power_ma > 500)
    medium_power_count = sum(1 for d in devices if not d.is_hub and 100 < d.power_ma <= 500)
    
    print("📈 電流使用状況サマリー:")
    print("-" * 40)
    print(f"合計消費電流: {total_current}mA")
    print(f"高消費デバイス (>500mA): {high_power_count}個")
    print(f"中消費デバイス (>100mA): {medium_power_count}個")
    print()
    
    if total_current > 2000:
        print("⚠️  警告: 合計消費電流が高いです。USBハブの電源確認を推奨")
    elif high_power_count > 2:
        print("⚠️  注意: 高消費デバイスが多いです。ポート分散を推奨")
    else:
        print("✅ 電流使用量は正常範囲内です")
    print()


def print_port_info() -> None:
    """USBポート情報を表示"""
    print("📝 USB規格別ポート情報:")
    print("-" * 40)
    print("🔌 システムのUSBポート:")
    
    output = run_command("lsusb -t")
    # 最初の10行のみ表示
    lines = output.strip().split('\n')[:10]
    for line in lines:
        if line.strip():
            print(line)
    print()


def print_usage_info() -> None:
    """使用方法を表示"""
    print("📋 使用方法:")
    print("  - MaxPowerはデバイスが要求する最大電流")
    print("  - 実際の消費電流はこれより少ない場合があります")
    print("  - ❌表示はポートの電流供給不足の可能性あり")
    print("  - USB3.0ポートは通常青いコネクタで識別可能")


def main() -> None:
    """メイン処理"""
    print_header()
    
    devices = collect_usb_devices()
    print_device_table(devices)
    print_summary(devices)
    print_port_info()
    print_usage_info()


if __name__ == "__main__":
    main()