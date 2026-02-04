{ self, system, pkgs, ... }:
let
  requirements = (pkgs.writeText "requirements.txt" ''
    # playbook deps
    cryptography # ansible-vault requirement
    configparser
    dnspython
    #flask_limiter
    flask
    kubernetes-validate
    kubernetes
    netaddr
    #pyOpenSSL
    python-hpilo
    #PyVmomi
    requests
    #selinux
    #uwsgi
    werkzeug

    # own deps
    jmespath # json_query filter
  '');
in

pkgs.mkShell {

  packages = with pkgs; [
    python311
    ansible_2_14
    ansible-lint
    self.outputs.packages.${system}.invhosts
  ];

  shellHook = ''
    echo "setting up venv"
    python -m venv .venv
    source .venv/bin/activate
    pip install -r ${requirements}

    echo "🚀 Development environment loaded!"
    echo "📦 $(python --version)"
    echo "📦 $(ansible --version)"
    echo ""
  '';

}