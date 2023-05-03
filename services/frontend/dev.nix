{ ... }:
{
  processes."${import ./name.nix}" = {
    runtimeConfig = {
    	PORT = 8080;
    	DATA_DIR = "/data";
   	};
  };
}