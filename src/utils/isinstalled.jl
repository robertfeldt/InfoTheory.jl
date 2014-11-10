isinstalled(pkg) = try
    isa(Pkg.installed(pkg), VersionNumber)
  catch
    return false
end
