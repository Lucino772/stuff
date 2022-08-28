import asyncio
import datetime as dt
import pandas as pd
import streamlit as st
from devices import load_devices

devices = load_devices()

if len(devices) > 0:
    _now = dt.datetime.now()
    # StreamLit
    st.title("Power consumption summary")

    # Show total total consumption for each device
    data = []
    for dev in devices:
        device_data = asyncio.run(dev.get_emeter_daily(year=_now.year))
        data.append({
            'device': dev.alias,
            'value': sum(device_data.values())
        })
    df = pd.DataFrame(data).set_index(['device'])
    st.bar_chart(df)

    # Draw a line chart to see the evolution for each device
    for dev in devices:
        device_data = asyncio.run(dev.get_emeter_daily(year=_now.year, month=_now.month))
        data = []
        for key, value in device_data.items():
            data.append({
                'day': key,
                'value': value
            })
        df = pd.DataFrame(data).set_index(['day'])
        st.text(f'Device: {dev.alias}')
        st.line_chart(df)
else:
    st.title("No devices were found !")