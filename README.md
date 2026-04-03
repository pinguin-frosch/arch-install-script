# artix-install-script
Simple script to install Artix Linux. It's only designed to run in my system,
so don't try to use it somewhere else, unless you want to use as inspiration to
make your own.

## Usage
First of all, the artix-linux-dinit ISO is necessary to run this script
1. Start artix-linux from the iso
2. Install git in the live iso
3. Clone this repo and cd into it
4. Change branch if necessary, otherwise skip this step
5. The packages to install can be changed from `./packages/` before starting the script
6. Run `bash install-1.sh`
7. Follow the instructions and then wait until it's installed

### Note
This was originally a script to install arch-linux. The tag v1.0-arch-final
still contains the last working version for that, but from now on I only
recommend using v2.0-artix-first or later. Ignore all the commits in between.
