{ config, lib, pkgs, ... }:

{
  options.hardware.amdgpu.loadInInitrd = lib.mkEnableOption (lib.mdDoc
    "loading `amdgpu` kernelModule at stage 1. (Add `amdgpu` to `boot.initrd.kernelModules`)"
  ) // {
    default = true;
  };
  options.hardware.amdgpu.opencl = lib.mkEnableOption (lib.mdDoc
    "rocm opencl runtime (Install rocmPackages.clr and rocmPackages.clr.icd)"
  ) // {
    default = true;
  };

  config = lib.mkMerge [
    {
      services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];

      hardware.opengl = {
        driSupport = lib.mkDefault true;
        driSupport32Bit = lib.mkDefault true;
      };
    }
    (lib.mkIf config.hardware.amdgpu.loadInInitrd {
      boot.initrd.kernelModules = [ "amdgpu" ];
    })
    (lib.mkIf config.hardware.amdgpu.opencl {
      hardware.opengl.extraPackages =
        if pkgs ? rocmPackages.clr
        then with pkgs.rocmPackages; [ clr clr.icd ]
        else with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];
    })
  ];
}
