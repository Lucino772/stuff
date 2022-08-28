import upnpclient

devices = upnpclient.discover()

igd = None
for dev in devices:
    if dev.device_type == "urn:schemas-upnp-org:device:InternetGatewayDevice:1":
        igd = dev

if dev is None:
    print("Didn't found the Internet Gateway Device !")
    exit(1)

print(igd.WANPPPConn0.GetNATRSIPStatus())
print(igd.WANPPPConn0.GetExternalIPAddress())
print(igd.WANPPPConn0.GetConnectionTypeInfo())
