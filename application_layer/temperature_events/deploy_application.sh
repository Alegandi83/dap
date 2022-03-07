#!/bin/bash

# Lab semplice
https://github.com/fabragaMS/ADPE2E/blob/master/Lab/Lab5/Lab5.md

# Lab complesso con function
https://github.com/Azure-Samples/modern-data-warehouse-dataops/tree/main/e2e_samples/temperature_events

# Simulatore dati
https://github.com/Azure-Samples/Iot-Telemetry-Simulator

# Attivazione simulatore
./loadtesting/IoTSimulator.ps1
-EventHubConnectionString "`"Endpoint=sb://ag83-evh-dev-00006.servicebus.windows.net/;SharedAccessKeyName=mypol;SharedAccessKey=73lOVdrfENcWc0uc7jvcZY9ugltrWFw9+FTKnoMBdGQ=;EntityPath=myeventhub`"" 
-DeviceCount $(DeviceCount) 
-MessageCount $(MessageCount) 
-Interval $(Interval) 
-ContainerCount $(ContainerCount) 
-ResourceGroup ag83-00006-dev-rg

# Activate Simulator
./loadtesting/IoTSimulator.ps1 -EventHubConnectionString "`"Endpoint=sb://ag83-evh-dev-00006.servicebus.windows.net/;SharedAccessKeyName=mypol;SharedAccessKey=73lOVdrfENcWc0uc7jvcZY9ugltrWFw9+FTKnoMBdGQ=;EntityPath=myeventhub`"" -ResourceGroup ag83-00006-dev-rg

# Endpoint Eventhub
Endpoint=sb://ag83-evh-dev-00006.servicebus.windows.net/;SharedAccessKeyName=mypol;SharedAccessKey=73lOVdrfENcWc0uc7jvcZY9ugltrWFw9+FTKnoMBdGQ=;EntityPath=myeventhub

# Sample Query
    SELECT System.Timestamp() AS OutTime, temperature, COUNT(*)   
    FROM [myEventHub-input] 
    --TIMESTAMP BY EntryTime  
    GROUP BY temperature, TumblingWindow(second,3) 

    SELECT *
    into myPowerBI
    FROM [myEventHub-input] 

# Activate CheckResult
./loadtesting/LoadTestCheckResult.ps1
-SubscriptionId 272f5f06-6693-48ae-975b-b5c7553539c2 
-ResourceGroup ag83-00006-dev-rg 
-EvhNamespace ag83-evh-dev-00006 
-EvhName myeventhub 

# Activate CheckResult
./loadtesting/LoadTestCheckResult.ps1 -SubscriptionId 272f5f06-6693-48ae-975b-b5c7553539c2 -ResourceGroup ag83-00006-dev-rg -EvhNamespace ag83-evh-dev-00006 -EvhName myeventhub 