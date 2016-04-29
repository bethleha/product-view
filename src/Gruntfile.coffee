#
# Grunt build spec
#

BUILD_ROOT = process.env.BUILD_ROOT or "../build"

module.exports = (grunt)->

    grunt.loadNpmTasks("grunt-contrib-coffee")
    grunt.loadNpmTasks("grunt-contrib-uglify")
    grunt.loadNpmTasks("grunt-contrib-less")
    grunt.loadNpmTasks("grunt-contrib-watch")
    grunt.loadNpmTasks("grunt-exec")

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json')

        exec: {
            init: {
                cmd: -> "mkdir -p #{BUILD_ROOT}/public"
            }
            copyStatic: {
                cmd: -> "cp -urf static/index.html static/css #{BUILD_ROOT}/public"
            }
        }

        coffee: {
            nodeapp: {
                expand  : true
                cwd     : "#{__dirname}/nodeapp/"
                dest    : "#{BUILD_ROOT}/nodeapp/"
                src     : ["**/*.coffee"]
                ext     : ".js"
            }
            test: {
                expand  : true
                cwd     : "#{__dirname}/testcoffee/"
                dest    : "#{BUILD_ROOT}/../test/"
                src     : ["*.coffee"]
                ext     : ".js"
            }
            static: {
                join    : true
                cwd     : "#{__dirname}/static/"
                dest    : "#{BUILD_ROOT}/public/prod-view-app.js"
                src     : [
                    "#{__dirname}/static/coffee/*.coffee"
                ]
            }
        }

        uglify: {
            options: {
                banner: '/*! Copyright (c) 2016 Sample-Prod-View Inc, All rights reserved. <%= pkg.description %> v<%= pkg.version %> <%= grunt.template.today("dd-mm-yyyy") %> */\n'
            }
            build: {
                dest    : "#{BUILD_ROOT}/public/prod-view-app.min.js"
                src     : ["#{BUILD_ROOT}/public/prod-view-app.js"]
            }
        }

        watch: {
            nodeapp: {
                files: ["appcoffee/**/*.coffee"]
                tasks: ["coffee:nodeapp"]
            }
            test: {
                files: ["testcoffee/**/*.coffee"]
                tasks: ["coffee:test"]
            }
            static: {
                files: ["static/coffee/**/*.coffee"]
                tasks: ["coffee:static"]
            }
            build: {
                files: ["#{BUILD_ROOT}/public/prod-view-app.js"]
                tasks: ["uglify:build"]
            }
        }
    })

    grunt.registerTask("default", [
        "exec:init"
        "coffee"
        "uglify"
        "exec:copyStatic"
    ])
#END
