# cache

A simple command line program to cache long running command line applications. 

## Installation

(have crystal)

make install

## Usage

    crcache --help  
    crcache v0.1.0
        -v, --version                    Show version
        -h, --help                       Show help
        -l, --list                       Show all cached commands
        -d CMD, --delete=CMD             Delete specified command
        -r, --refresh                    Refresh all cached commands
        -t, --test                       Refresh test command
        -D, --dump                       Display all cached results

    crcache ansiweather

Why? I have a few programs that take more than a few milliseconds to run, that I like
to have run everytime I open a terminal window. I now have a cron job that keeps the
data fresh (crcache -r) and then display the cached results when starting a terminal.

## Contributing

1. Fork it (<https://github.com/your-github-user/cache/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Patrick Hurley](https://github.com/your-github-user) - creator and maintainer

