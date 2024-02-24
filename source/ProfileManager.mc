//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;

class ProfileManager 
{

    // Environmental Sensing Service
    public const ENVIRONMENTAL_SENSING_SERVICE = BluetoothLowEnergy.stringToUuid("0000" + "181A" + "-0000-1000-8000-00805F9B34FB");
    public const TEMPERATURE_CHARACTERISTIC = BluetoothLowEnergy.stringToUuid("0000" + "2A6E" + "-0000-1000-8000-00805F9B34FB");
    public const HUMIDITY_CHARACTERISTIC  = BluetoothLowEnergy.stringToUuid("0000" + "2A6F" + "-0000-1000-8000-00805F9B34FB");
    public const PARTICULATE_MATTER_CHARACTERISTIC  = BluetoothLowEnergy.stringToUuid("0000" + "2BD6" + "-0000-1000-8000-00805F9B34FB");
    public const CARBON_MONOXIDE_CHARACTERISTIC  = BluetoothLowEnergy.stringToUuid("0000" + "2BD0" + "-0000-1000-8000-00805F9B34FB");

    private const _airSenseProfileDef = 
    {
        :uuid => ENVIRONMENTAL_SENSING_SERVICE,
        :characteristics => [{
            :uuid => TEMPERATURE_CHARACTERISTIC,
            :descriptors => [BluetoothLowEnergy.cccdUuid()]
        }, 
        {
            :uuid => HUMIDITY_CHARACTERISTIC,
            :descriptors => [BluetoothLowEnergy.cccdUuid()]
        },
        {
            :uuid => PARTICULATE_MATTER_CHARACTERISTIC,
            :descriptors => [BluetoothLowEnergy.cccdUuid()]
        },
        {
            :uuid => CARBON_MONOXIDE_CHARACTERISTIC,
            :descriptors => [BluetoothLowEnergy.cccdUuid()]
        } ]
    };

    //! Register the bluetooth profile
    public function registerProfiles() as Void 
    {
        BluetoothLowEnergy.registerProfile(_airSenseProfileDef);
    }
}
