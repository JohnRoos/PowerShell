# Credit goes to BeowulfNode42 on Stackoverflow. Thank you.
# http://stackoverflow.com/questions/5898843/c-sharp-get-system-file-cache-size

$source = @"
using System;
using System.Runtime.InteropServices;

namespace MyTools
{
    public static class cache
    {

        [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool GetSystemFileCacheSize(
            ref IntPtr lpMinimumFileCacheSize,
            ref IntPtr lpMaximumFileCacheSize,
            ref IntPtr lpFlags
            );

        public static bool Get( ref IntPtr a, ref IntPtr c, ref IntPtr d )
        {
            IntPtr lpMinimumFileCacheSize = IntPtr.Zero;
            IntPtr lpMaximumFileCacheSize = IntPtr.Zero;
            IntPtr lpFlags = IntPtr.Zero;

            bool b = GetSystemFileCacheSize(ref lpMinimumFileCacheSize, ref lpMaximumFileCacheSize, ref lpFlags);

            a = lpMinimumFileCacheSize;
            c = lpMaximumFileCacheSize;
            d = lpFlags;
            return b;
        }
    }
}
"@

Add-Type -TypeDefinition $source -Language CSharp

# Init variables
$SFCMin = 0
$SFCMax = 0
$SFCFlags = 0
$b = [MyTools.cache]::Get( [ref]$SFCMin, [ref]$SFCMax, [ref]$SFCFlags )

#typecast values so we can do some math with them
$SFCMin = [long]$SFCMin
$SFCMax = [long]$SFCMax
$SFCFlags = [long]$SFCFlags

write-output "Return values from GetSystemFileCacheSize are: "
write-output "Function Result : $b"
write-output "            Min : $SFCMin"
write-output ("            Max : $SFCMax ( " + $SFCMax / 1024 / 1024 / 1024 + " GiB )")
write-output "          Flags : $SFCFlags"