todo
=====

example rebar3 plugin

Build
-----

    $ rebar3 compile

Use
---

Add the plugin to your rebar config:

    {plugins, [
        { todo, ".*", {git, "https://github.com/drvspw/rebar3-todo-plugin.git", {tag, "0.1.0"}}}
    ]}.

Then just call your plugin directly in an existing application:


    $ rebar3 todo
    ===> Fetching todo
    ===> Compiling todo
    <Plugin Output>

Blindly copied from rebar3 todo plugin tutorial
================================================
