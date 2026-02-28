{
  description = "ntfy.sh push notification CLI wrapper";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "ntfy-push";
          version = "0.1.0";

          src = ./.;

          nativeBuildInputs = [ pkgs.makeWrapper ];
          buildInputs = [ pkgs.curl ];

          installPhase = ''
            mkdir -p $out/bin
            cp ntfy-push.sh $out/bin/ntfy-push
            chmod +x $out/bin/ntfy-push
            
            wrapProgram $out/bin/ntfy-push \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.curl ]}
          '';
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/ntfy-push";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.curl pkgs.shellcheck ];
        };
      }
    );
}
