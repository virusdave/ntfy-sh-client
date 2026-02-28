{
  description = "ntfy.sh push notification CLI wrapper";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlays.default = final: prev: {
        ntfy-sh-client = final.stdenv.mkDerivation {
          name = "ntfy-sh-client";
          version = "1.0.0";

          src = ./.;

          nativeBuildInputs = [ final.makeWrapper ];
          buildInputs = [ final.curl ];

          installPhase = ''
            mkdir -p $out/bin
            cp ntfy-push.sh $out/bin/ntfy-push
            chmod +x $out/bin/ntfy-push

            wrapProgram $out/bin/ntfy-push \
              --prefix PATH : ${final.lib.makeBinPath [ final.curl ]}
          '';
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
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
