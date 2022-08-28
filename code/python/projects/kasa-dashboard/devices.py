import asyncio
from kasa import Discover

def load_devices():
    async def _load_devices():
        devices = []
        _devices = await Discover.discover(target='192.168.1.255')
        for addr, dev in _devices.items():
            print(f'Device Found: {addr}, {dev}')
            await dev.update()
            devices.append(dev)
        return devices
    return asyncio.run(_load_devices())
