name 'genome_scipy_jupyter'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures genome_scipy_jupyter'
long_description 'Installs/Configures genome_scipy_jupyter'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/tyronemsaunders/genome_scipy/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/tyronemsaunders/genome_scipy/chef-repo/wrapper_cookbooks/genome_scipy_jupyter'

depends 'openssl',           '~> 7.1.0'
depends 'nginx',             '~> 7.0.0'
depends 'poise-python',      '~> 1.6.0'
depends 'nodejs',            '~> 4.0.0'

depends 'genome_scipy_base'
depends 'genome_scipy_github'
depends 'genome_scipy_openssl'
depends 'genome_scipy_nginx'
depends 'genome_scipy_nodejs'
depends 'genome_scipy_python'
depends 'genome_scipy_supervisor'