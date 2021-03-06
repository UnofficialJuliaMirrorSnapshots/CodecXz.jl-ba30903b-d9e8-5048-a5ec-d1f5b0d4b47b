using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["liblzma"], :liblzma),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/bicycle1885/XzBuilder/releases/download/v1.0.2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/XzBuilder.v5.2.4.aarch64-linux-gnu.tar.gz", "11c29c41ab3e16010030d759cbbbd037aeab7637fe961cd52cb283830243344d"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/XzBuilder.v5.2.4.aarch64-linux-musl.tar.gz", "4ccfbd312d3d4909bbde53e92bd9f65a3eb66bc5785cffcae50bb12d0480667a"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/XzBuilder.v5.2.4.arm-linux-gnueabihf.tar.gz", "3f08b7e8a826a02f80812c988559824a01ad2329f93b06c2585bdc5b162f19bc"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/XzBuilder.v5.2.4.arm-linux-musleabihf.tar.gz", "ca7c5dd3a2bee4e77e4bfe42486073c28ae9e331d6774cca6026653668d3d0de"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/XzBuilder.v5.2.4.i686-linux-gnu.tar.gz", "2d1c2a5bd360e188685c7fabc91587f996a124aa9c8dd6b30699f7cb86327ef8"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/XzBuilder.v5.2.4.i686-linux-musl.tar.gz", "50e9ea6c86b1f1c8ede8540bec71c4026f629302245d22cafc797460e9746f2d"),
    Windows(:i686) => ("$bin_prefix/XzBuilder.v5.2.4.i686-w64-mingw32.tar.gz", "15f89b7c7172b4ea3b516413668187189a5ad740c2ed47ac5b301e58d3e02319"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/XzBuilder.v5.2.4.powerpc64le-linux-gnu.tar.gz", "23f101b8bf694052075e731033741948f1d8a3171d8c180c4965a93c31f1d20c"),
    MacOS(:x86_64) => ("$bin_prefix/XzBuilder.v5.2.4.x86_64-apple-darwin14.tar.gz", "6c581162e6cddb29fd2d3a3c6d99a2b03af11fc20da646c84175990e097e0f4c"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/XzBuilder.v5.2.4.x86_64-linux-gnu.tar.gz", "30a751525ed749d2f8ab6f3e00a05dee2920245d628c0a6552a9ce29207055d8"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/XzBuilder.v5.2.4.x86_64-linux-musl.tar.gz", "efa92ed54b25ab7bd738d3de047f9b151d69b0b641405ccec530ef958abd3334"),
    FreeBSD(:x86_64) => ("$bin_prefix/XzBuilder.v5.2.4.x86_64-unknown-freebsd11.1.tar.gz", "306b1e8da26d9f1337a0863825032ac5acb52ef959bf1a496bbb6c5008988379"),
    Windows(:x86_64) => ("$bin_prefix/XzBuilder.v5.2.4.x86_64-w64-mingw32.tar.gz", "4f0d5bb284273b664867f67d150d2f75828e1e5a6a047e7be9dd870d443c146c"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
