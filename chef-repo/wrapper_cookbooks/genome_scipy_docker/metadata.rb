name 'genome_scipy_docker'
maintainer 'Tyrone Saunders'
maintainer_email ''
license 'All Rights Reserved'
description 'Installs/Configures genome_scipy_docker'
long_description 'Installs/Configures genome_scipy_docker'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/tyronemsaunders/genome_scipy/issues'

# The `source_url` points to the development reposiory for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/tyronemsaunders/genome_scipy/chef-repo/wrapper_cookbooks/genome_scipy_docker'

depends 'chef-apt-docker', '~> 2.0.4'
depends 'docker', '~> 2.17.0'