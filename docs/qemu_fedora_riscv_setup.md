# How to start RISC-V Fedora 
Scot W. Stevenson <scot.stevenson@gmail.com>   
First version: 23. October 2019
This version: 23. October 2019    

The easiest way to get started with a complete RISC-V Linux system is through
the QEMU emulator and Fedora pre-built images. Simply follow the instructions at
https://wiki.qemu.org/Documentation/Platforms/RISCV#Booting_64-bit_Fedora : 

First, go to https://fedorapeople.org/groups/risc-v/disk-images/ and download
everything to a folder "Fedora". Then uncompress the disk image:

```
        sudo apt install xzdec  # Was not installed by default on Ubuntu
        xzdec -d stage4-disk.img.xz > stage4-disk.img
```

Next, create a shell script `fedora-riscv64.sh` in the same folder with the
content:

```
  qemu-system-riscv64 \
   -nographic \
   -machine virt \
   -smp 4 \
   -m 2G \
   -kernel bbl \
   -object rng-random,filename=/dev/urandom,id=rng0 \
   -device virtio-rng-device,rng=rng0 \
   -append "console=ttyS0 ro root=/dev/vda" \
   -device virtio-blk-device,drive=hd0 \
   -drive file=stage4-disk.img,format=raw,id=hd0 \
   -device virtio-net-device,netdev=usernet \
   -netdev user,id=usernet,hostfwd=tcp::10000-:22
```

Run the shell script. The terminal window you are using will show the console.
Login with "root" as the user name and "riscv" as the password. You'll want to
change that first thing with `passwd`. Create a normal user, for instance:

```
        useradd --home /home/scot scot
        passwd scot
```

The Fedora version currently available on the server is seriously old. Upgrade
it following https://docs.fedoraproject.org/en-US/quick-docs/dnf-system-upgrade/
as root. This can take some time.  

```
        dnf upgrade --refresh
        dnf install dnf-plugin-system-upgrade
        dnf system-upgrade download --refresh --releasever=31
        dnf system-upgrade reboot
```

Fedora comes with a horribly hamstrung version of vim, which will not do at all:

```
        dnf install vim-enhanced
```

Then you can logout. As described in
https://fedorapeople.org/groups/risc-v/disk-images/readme.txt , you can ssh into
the QEMU instance of Fedora at port 10000 from the hostmachine:

```
        ssh -p 10000 scot@localhost
```

The console is limited and will not let you resize the window.

