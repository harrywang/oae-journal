class localconfig::hostnames {

    # Add a couple of hostnames that can be used as tenants
    host { 'admin.icoursemap.com': ip => '127.0.0.1' }
    host { 'tenant1.icoursemap.com': ip => '127.0.0.1' }
    host { 'tenant2.icoursemap.com': ip => '127.0.0.1' }
    host { 'tenant3.icoursemap.com': ip => '127.0.0.1' }

}

