Home-Manager modules
====================

This flake exposes several home-manager modules which are opinionated for my personal usage.
Whole home configuration is setup based on two configuration values, or rather sets:

### `config.purpose`
Which tells purpose of current user in given environment.
Main question is how would you like to use current environment?
- Would you like to develop some stuff?               `dev`
- Would you like to play games?                       `games`
- Would you like to use it as daily driver?           `daily`
- Would you like to watch media?                      `media`
- Would you like to have access to your VPN networks? `connectivity`

### `config.environment.capabilities`
Another important aspect is what kind of things is current environment capable?
- Does you system have some GUI? `gui`
