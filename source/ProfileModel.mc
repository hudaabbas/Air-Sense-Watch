//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;

class ProfileModel 
{
    private var _service as Service?;
    private var _profileManager as ProfileManager;
    private var _pendingNotifies as Array<Characteristic>;

    private var _temp as Numeric?;
    private var _cO2 as Numeric?;
    private var _humidity as Numeric?;
    private var _pm25 as Numeric?;
   
    //! Constructor
    //! @param delegate The BLE delegate for the model
    //! @param profileManager The profile manager for this model
    //! @param device The current device
    public function initialize(delegate as BLEDelegate, profileManager as ProfileManager, device as Device) 
    {
        delegate.notifyDescriptorWrite(self);
        delegate.notifyCharacteristicChanged(self);

        _profileManager = profileManager;
        _service = device.getService(profileManager.ENVIRONMENTAL_SENSING_SERVICE);

        _pendingNotifies = [] as Array<Characteristic>;

        var service = _service;
        if (service != null) 
        {

            var characteristic = service.getCharacteristic(profileManager.CARBON_MONOXIDE_CHARACTERISTIC );
            if (null != characteristic) 
            {
                _pendingNotifies = _pendingNotifies.add(characteristic);
            }

            characteristic = service.getCharacteristic(profileManager.HUMIDITY_CHARACTERISTIC);
            if (null != characteristic) 
            {
                _pendingNotifies = _pendingNotifies.add(characteristic);
            }

            characteristic = service.getCharacteristic(profileManager.TEMPERATURE_CHARACTERISTIC);
            if (null != characteristic) 
            {
                _pendingNotifies = _pendingNotifies.add(characteristic);
            }

            characteristic = service.getCharacteristic(profileManager.PARTICULATE_MATTER_CHARACTERISTIC);
            if (null != characteristic) 
            {
                _pendingNotifies = _pendingNotifies.add(characteristic);
            }
        }
        activateNextNotification();
    }
  
    //! Handle a characteristic being changed
    //! @param char The characteristic that changed
    //! @param value The updated value of the characteristic
    public function onCharacteristicChanged(char as Characteristic, value as ByteArray) as Void 
    {
        switch (char.getUuid()) 
        {
            case _profileManager.TEMPERATURE_CHARACTERISTIC:
                _temp = value.decodeNumber(Lang.NUMBER_FORMAT_UINT16, {:endianness => Lang.ENDIAN_LITTLE}) / 100.0;
                WatchUi.requestUpdate();
                break;

            case _profileManager.HUMIDITY_CHARACTERISTIC:
                _humidity = value.decodeNumber(Lang.NUMBER_FORMAT_UINT16, {}) / 100.0;
                WatchUi.requestUpdate();
                break;
            case _profileManager.CARBON_MONOXIDE_CHARACTERISTIC :
                
                _cO2 = value.decodeNumber(Lang.NUMBER_FORMAT_UINT16, {});
                WatchUi.requestUpdate();
                break;
            case _profileManager.PARTICULATE_MATTER_CHARACTERISTIC :
                
                _pm25 = value.decodeNumber(Lang.NUMBER_FORMAT_UINT16, {}) / 1000.0;
                WatchUi.requestUpdate();
                break;            
        }
    }

    //! Handle the completion of a write operation on a descriptor
    //! @param descriptor The descriptor that was written
    //! @param status The BluetoothLowEnergy status indicating the result of the operation
    public function onDescriptorWrite(descriptor as Descriptor, status as Status) as Void 
    {
        if (BluetoothLowEnergy.cccdUuid().equals(descriptor.getUuid())) 
        {
            processCccdWrite();
        }
    }

    
    
    public function getTemp() as Numeric? 
    {
        return _temp;
    }
    public function getCO2() as Numeric? 
    {
        return _cO2;
    }
    public function getHumidity() as Numeric? 
    {
        return _humidity;
    }
    public function getPM25() as Numeric? 
    {
        return _pm25;
    }


    //! Write the next notification to the descriptor
    private function activateNextNotification() as Void 
    {
        if (_pendingNotifies.size() == 0) 
        {
            return;
        }

        var char = _pendingNotifies[0];
        var cccd = char.getDescriptor(BluetoothLowEnergy.cccdUuid());
        if (cccd != null) 
        {
            cccd.requestWrite([0x01, 0x00]b);
        }
    }

    //! Process a CCCD write operation
    private function processCccdWrite() as Void 
    {
        if (_pendingNotifies.size() > 1) 
        {
            _pendingNotifies = _pendingNotifies.slice(1, _pendingNotifies.size());
            activateNextNotification();
        } 
        else 
        {
            _pendingNotifies = [] as Array<Characteristic>;
        }

    }

}
    

    
    
   
