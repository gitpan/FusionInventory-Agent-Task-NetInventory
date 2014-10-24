#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use FusionInventory::Agent::Task::NetInventory::Manufacturer::Cisco;

my @mac_tests = (
    # each item is an arrayref of three elements:
    # - input data structure
    # - output data structure
    # - test explication
    [
        {
            0 => {
                CONNECTIONS => {
                    CONNECTION => [
                    ]
                },
                MAC => 'X',
            }
        },
        {
            0 => {
                CONNECTIONS => {
                    CONNECTION => [
                        { MAC => '00:1C:F6:C5:64:19' }
                    ]
                },
                MAC => 'X',
            }
        },
        'connection mac address retrieval'
    ],
    [
        {
            0 => {
                CONNECTIONS => {
                    CONNECTION => [
                    ],
                    CDP => 1,
                },
                MAC => 'X',
            }
        },
        {
            0 => {
                CONNECTIONS => {
                    CONNECTION => [
                    ],
                    CDP => 1,
                },
                MAC => 'X',
            }
        },
        'connection mac address retrieval, connection has CDP'
    ],
    [
        {
            0 => {
                CONNECTIONS => {
                    CONNECTION => [
                    ],
                },
                MAC => '00:1C:F6:C5:64:19',
            }
        },
        {
            0 => {
                CONNECTIONS => {
                    CONNECTION => [
                    ],
                },
                MAC => '00:1C:F6:C5:64:19',
            }
        },
        'connection mac address retrieval, same mac address as the port'
    ],
);

plan tests => scalar @mac_tests;

my $walks = {
    dot1dBasePortIfIndex => {
        OID => '.1.3.6.1.2.17.1.4.1.2'
    },
    dot1dTpFdbAddress => {
        OID => '.1.3.6.1.2.1.17.4.3.1.1'
    },
    dot1dTpFdbPort => {
        OID => '.1.3.6.1.2.1.17.4.3.1.2'
    },
};

my $results = {
    VLAN => {
        1 => {
            dot1dTpFdbPort => {
                '.1.3.6.1.2.1.17.4.3.1.2.0.28.246.197.100.25' => 2307,
            },
            dot1dTpFdbAddress => {
                '.1.3.6.1.2.1.17.4.3.1.1.0.28.246.197.100.25' => '0x001CF6C56419',
            },
            dot1dBasePortIfIndex => {
                '.1.3.6.1.2.17.1.4.1.2.2307' => 0,
            }
        }
    }
};

foreach my $test (@mac_tests) {
    FusionInventory::Agent::Task::NetInventory::Manufacturer::Cisco::setConnectedDevicesMacAddress(
        results => $results, ports => $test->[0], walks => $walks, vlan_id => 1
    );

    is_deeply(
        $test->[0],
        $test->[1],
        $test->[2],
    );
}
