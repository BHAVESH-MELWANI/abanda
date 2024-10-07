# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-23.11"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.nodejs_20
    pkgs.nodejs_20
    pkgs.jdk21_headless
    pkgs.gradle
    pkgs.socat
  ];
  # Sets environment variables in the workspace
  env = { EXPO_USE_FAST_RESOLVER = 1; };
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "msjsdiag.vscode-react-native"
      "fwcd.kotlin"
    ];
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = {
        install-and-prebuild = ''
          npm ci --prefer-offline --no-audit --no-progress --timing && npm i @expo/ngrok@^4.1.0 && npx -y expo install expo-dev-client && npx -y expo prebuild --platform android
          # Add more memory to the JVM
          sed -i 's/org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m/org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m/' "android/gradle.properties"
        '';
      };
      # Runs when a workspace restarted
      onStart = {
        forward-ports = ''
          socat -d -d TCP-LISTEN:5554,reuseaddr,fork TCP:$(cat /etc/resolv.conf | tail -n1 | cut -d " " -f 2):5554
        '';
        connect-device = ''
          adb -s localhost:5554 wait-for-device 
        '';
        android = ''
          npm run android
        '';
      };
    };
    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = [ "npm" "run" "web" "--" "--port" "$PORT" ];
          manager = "web";
        };
        android = {
          # noop
          command = [ "tail" "-f" "/dev/null" ];
          manager = "web";
        };
      };
    };
  };
}
