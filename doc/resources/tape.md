tape resource
=============

A tela **tape** resource represents a tape device provided by the CCW tape
device drivers. A tape resource is identified by its CCW device ID,
e.g. '0.0.0181'. It provides the following attributes:

```YAML
system:
  tape:
    busid: <busid>
    type: ccw
    sysfs: <sysfs_path>
    state: <state>
    medium_state: <medium_state>
    ccw:
      chpid:
        <chpid_data>
      online: 0|1
      cutype: <cutype_and_model>
      devtype: <devtype_and_model>
    n_char_dev:
      cdev: <chardev_name>
    r_char_dev:
      cdev: <chardev_name>
    allow_write: <flag>
```
Additionally the following system attributes related to **tape** resources
are provided:
```YAML
system:
  tape_count_available: <number>
  tape_count_total: <number>
```

### Environment variables

Test programs can access actual values of tape drive attributes using environment
variables named:

```
   TELA_SYSTEM_TAPE_<name>_<path>
```

where

  - `<name>` is the symbolic name given to a tape resource in the test YAML
    file
  - `<path>` is an attribute's uppercase YAML path with underscores in place of
    non-alphanumeric characters.

Example:

```
TELA_SYSTEM_TAPE_mytape=0.0.0181
TELA_SYSTEM_TAPE_mytape_TYPE=ccw
TELA_SYSTEM_TAPE_mytape_SYSFS=/sys/bus/ccw/drivers/tape_34xx/0.0.0181
TELA_SYSTEM_TAPE_mytape_BUSID=0.0.0181
TELA_SYSTEM_TAPE_mytape_STATE=UNUSED
TELA_SYSTEM_TAPE_mytape_MEDIUM_STATE=1
TELA_SYSTEM_TAPE_mytape_CCW_ONLINE=1
TELA_SYSTEM_TAPE_mytape_CCW_DEVTYPE=3490/54
TELA_SYSTEM_TAPE_mytape_CCW_CUTYPE=3490/54
TELA_SYSTEM_TAPE_mytape_CCW_CHPID_mychpid=0.1c
TELA_SYSTEM_TAPE_mytape_CCW_CHPID_mychpid_SYSFS=/sys/devices/css0/chp0.1c
TELA_SYSTEM_TAPE_mytape_CCW_CHPID_mychpid_CONFIGURED=1
TELA_SYSTEM_TAPE_mytape_CCW_CHPID_mychpid_ONLINE=1
TELA_SYSTEM_TAPE_mytape_CCW_CHPID_mychpid_TYPE=0x1b
TELA_SYSTEM_TAPE_mytape_CCW_CHPID_mychpid_ALLOW_OFFLINE=0
TELA_SYSTEM_TAPE_mytape_CCW_CHPID_mychpid_BUSID=0.1c
TELA_SYSTEM_TAPE_mytape_CCW_CHPID_mychpid_CHID=0x02c1
TELA_SYSTEM_TAPE_mytape_CCW_CHPID_mychpid_CHID_EXTERNAL=1
TELA_SYSTEM_TAPE_mytape_R_CHAR_DEV_CDEV=rtibm0
TELA_SYSTEM_TAPE_mytape_N_CHAR_DEV_CDEV=ntibm0
TELA_SYSTEM_TAPE_mytape_ALLOW_WRITE=0
TELA_SYSTEM_TAPE_COUNT_TOTAL=2
TELA_SYSTEM_TAPE_COUNT_AVAILABLE=2
```

### Attribute description

This section describes the attributes that are available for tape resources.
The value of these attributes can be evaluated in test programs
(see 'Environment variables' above) and for defining test requirements
(see 'Attribute conditions' in [Test resources](../resources.md)).


  - **`system/tape/busid:`**  *(type: scalar)*

    The bus-ID of the tape device.

  - **`system/tape/type:`**  *(type: scalar)*

    Tape device type. Valid value is 'ccw'.

  - **`system/tape/sysfs:`**  *(type: scalar)*

    Sysfs-path associated with the tape device.

  - **`system/tape/state:`**  *(type: scalar)*

    State of the physical tape device, for example 'UNUSED'.

  - **`system/tape/medium_state:`**  *(type: scalar)*

    The current state of the tape cartridge. Valid values are 0 for
    'No information on cartridge state', 1 for 'Cartridge is loaded', and 2 for
    'No cartridge is loaded'.

  - **`system/tape/ccw/chpid:`** *(type: object)*

    A CHPID that is defined for the tape device. See [chpid resource](chpid.md)
    for a list of available chpid resource attributes.

    Example: Test requires a tape device with a CHPID that can be varied offline.

    ```YAML
    system:
      tape mytape:
        ccw:
          chpid mychpid:
            allow_offline: 1
    ```

    Note: By listing a tape device in the resource YAML file, all associated
    CHPIDs are automatically registered as available for testing. Also note that
    to override attribute values of a tape device's CHPID in a resource YAML
    file, the attributes must be specified in the corresponding CHPID section
    (system/chpid) and not in the tape device's CHPID section
    (system/tape/chpid).

  - **`system/tape/ccw/online:`**  *(type: scalar)*

    Online state of the tape device. Valid values are 0 for 'offline' and 1 for
    'online'. Note that if a test YAML file does not contain a condition for
    the online attribute, both online and offline tape devices will match.

    Example: Test requires an online tape device

    ```YAML
    system:
      tape mytape:
        online: 1
    ```

  - **`system/tape/ccw/cutype:`**  *(type: scalar)*

    Control unit type and model information for the tape device, for example
    '3490/54'.

  - **`system/tape/ccw/devtype:`**  *(type: scalar)*

    Device type and model information for the tape device, for example
    '3490/54'.

  - **`system/tape/n_char_dev/cdev:`**  *(type: scalar)*

    Non-rewinding character device name. This attribute is only available when
    the tape device is online.

  - **`system/tape/r_char_dev/cdev:`**  *(type: scalar)*

    Rewinding character device name. This attribute is only available when the
    tape device is online.

  - **`system/tape/allow_write:`**  *(type: scalar)*

    This attribute indicates whether a test case is allowed to change the
    contents of the tape device. Valid values are:

      - 0: Test case must not write to tape device (default)
      - 1: Test case is allowed to write to tape device

    Example: Test requires a tape device that may be written to

    ```YAML
    system:
      tape a:
        allow_write: 1
    ```

    Note: A non-default value for this attribute must be specified manually
    in the test environment file as it cannot be determined automatically.

  - **`system/tape_count_available:`** *(type: number)*

    Number of tape resource objects that are available for test cases.

  - **`system/tape_count_total:`** *(type: number)*

    Total number of tape resource objects that are defined on the
    test system.

    Example: Test requires a system with no tape device.

    ```YAML
    system:
      tape_count_total: 0
    ```
