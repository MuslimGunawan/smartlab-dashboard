<?php

namespace App\Services;

class WakeOnLanService
{
    /**
     * Send Wake-on-LAN magic packet to a target MAC address.
     *
     * @param string $macAddress e.g. "00:1A:2B:3C:4D:5E" or "00-1A-2B-3C-4D-5E"
     * @param string $broadcastIp e.g. "255.255.255.255" or lab subnet broadcast
     * @param int $port e.g. 9 or 7
     * @return bool
     */
    public static function wake(string $macAddress, string $broadcastIp = '255.255.255.255', int $port = 9): bool
    {
        // Strip non-hex characters
        $cleanMac = preg_replace('/[^0-9a-fA-F]/', '', $macAddress);

        if (strlen($cleanMac) !== 12) {
            return false;
        }

        // Convert MAC address to binary string
        $binaryMac = pack('H*', $cleanMac);

        // Magic Packet: 6 bytes of 0xFF + 16 repetitions of binary MAC (total 102 bytes)
        $magicPacket = str_repeat(chr(0xFF), 6) . str_repeat($binaryMac, 16);

        // Send via UDP socket or stream fallback
        try {
            if (function_exists('socket_create')) {
                $socket = @socket_create(AF_INET, SOCK_DGRAM, SOL_UDP);
                if ($socket !== false) {
                    socket_set_option($socket, SOL_SOCKET, SO_BROADCAST, 1);
                    $sentBytes = @socket_sendto($socket, $magicPacket, strlen($magicPacket), 0, $broadcastIp, $port);
                    socket_close($socket);
                    if ($sentBytes !== false && $sentBytes === strlen($magicPacket)) {
                        return true;
                    }
                }
            }

            // Universal fallback: stream_socket_client without requiring ext-sockets
            $fp = @stream_socket_client("udp://{$broadcastIp}:{$port}", $errno, $errstr, 2);
            if ($fp) {
                $written = @fwrite($fp, $magicPacket);
                fclose($fp);
                return $written === strlen($magicPacket);
            }

            return false;
        } catch (\Throwable $e) {
            return false;
        }
    }
}
