# Contentful

Contentful is a Rails plugin to make it easy to write tests that compare the HTML content of rendered views against expected content stored in files, and to create, compare against, and update that expected content.

It comes from the prehistoric times of 2007 when people used plugins in Rails and a site called rubyforge.org. It is now the end of 2014 and all those things are basically dead.

The idea the code enshrines is, I stubbornly insist, valuable. So I've put it here.

[Here's a blog post that explains the idea and links onwards.](http://anthonybailey.net/blog/2007/07/19/regression-therapy-contentful-testing)

## Installation

Contentful should be installed as a plug-in to a Rails app:
```
~rails_app$ script/plugin install svn://rubyforge.org/var/svn/contentful
```

As usual for plug-in installation, if <code>vendor/plugins</code> is already under Subversion source control, this will add Contentful as <code>svn:external</code>; otherwise it just copies it.

To test the plugin, you should run
```
~rails_app/vendor/plugins/contentful$ rake
```
or
```
~rails_app$ rake test:plugins
```

## Assertions

The core of Contentful is the <code>assert_contentful</code> method mixed into <code>Test::Unit::TestCase</code>. When called without arguments from one of your functional or integration tests, this assertion checks the rendered HTML page content (in <code>@response.body</code>) against expected content stored as an <code>expected.html</code> file on disk.

Files for assertions made in <code>SomeExampleTest#test_method</code> live in the directory <code>test/contentful/some_example/method/</code>.

The assertion compares the content as <code>HTML::Nodes</code>, which normalizes case, spacing and quoting within the mark-up.

If the assertion fails, then the changed content is written out as a temporary changed.html file along with <code>expected.to_diff</code> and <code>changed.to_diff</code> versions of the content for comparison with a line-based diff program. When the assertion passes, any existing temporary files are removed.

If no expected content yet exists, the assertion passes and noisily creates expected content from the current content as a side effect.

## Extensions

An optional last argument to <code>assert_contentful</code> supplies a <code>Symbol</code> as a label. This label is prefixed to the associated content files. If you use two assertions in the same test, Contentful will complain unless you supply labels to distinguish them.

An optional first argument to <code>assert_contentful</code> supplies an <code>HTML::Node</code> to use instead of the <code>@response.body</code>.

To check only part of the response, use <code>select_contentful</code> instead and supply a CSS selector. By default the selector is used as a label, but you can supply one yourself to override this.

Contentful works with XML responses as well as HTML ones, putting content into expected.xml and changed.xml files.

## Workflow

To get value from these sort of tests, you need to be able to manage changes to content effectively. Contentful attempts to make it easy to review such changes and accept them when appropriate.

When a Contentful assertion fails, it displays a diff command-line to inspect the change. (Set your <code>DIFF</code> environment variable to alter the program used for diffing from the default diff.)

To accept an individual change, you could copy the changed content over the expected content; but since expected content is created when absent, a handy shortcut is to delete the current expected content and re-run the test.

Alternatively, you can also use Rake to test, diff and accept changes. The <code>contentful:test</code> task (also available as the shorter <code>test:content</code>) inspects the current directory structure within <code>test/contentful</code> and runs the corresponding subset of your functional and integration tests; <code>contentful:diff</code> (or <code>test:diff</code>) runs your diff program on all changes currently present; and <code>contentful:accept</code> (or <code>test:accept</code>) updates expected content with current changes. You can run any of these tasks within a subdirectory of <code>test/contentful</code> to limit their scope.

## Virtues and Vises

So-called regression tests have something of a bad name. (Literally - hence my referring to them as "content" tests here.) They can lead you to a place where the expectations of too many tests are trivially broken in passing. Failing tests should tell you something useful, and be quick to accept your judgement if all is well; poorly conceived regression tests can instead be expensive to maintain.

But it doesn't have to be that way.

The workflow section above describes Contentful's attempt to minimize the maintainence cost, and you can build on this for your particular needs. When expecting changes to content, a quick eyeball or grep of the resulting diffs is often all the feedback you need before accepting them. Heavier lifting can be assisted by better machinery: a previous successful set of content tests for a team project involved a little file-associated scripting to select, diff and accept multiple changes from within a file browser GUI.

Additionally, you can DRY up your content expectations using <code>select_contentful</code> to e.g. avoid duplicating the testing of the content of navigational sidebars across every test.

Personally, I like to keep my content tests fully live, and to minimize then pay their maintainence tax - their pedantry catches accidental errors surprisingly often. But even if you're not convinced of their permanent virtue, you can still use content tests as a temporary vice.

That is a British pun - outside of the UK, the term (due [to Michael Feathers](http://www.artima.com/weblogs/viewpost.jsp?thread=171323)) is spelled "vise." The idea of a coding vise is to temporarily add machinery (such as [sensing variables](http://www.artima.com/weblogs/viewpost.jsp?thread=170799)) to lock down a behaviour that you wish to preserve, perform a pervasive/risky refactoring, and then remove the machinery before checking your changes in.

Contentful serves as a very powerful vise for changes such as refactoring your form builders, or moving from eRB to a nicer templating system such as a [slim builder](http://anthonybailey.livejournal.com/29792.html) like [Markaby](http://markaby.rubyforge.org). These kinds of change can break your content in a variety of unexpected ways. You can protect yourself very cheaply, covering everything generated in all existing tests by adding the following to your <code>config/environment.rb</code>
```
CONTENTFUL_AUTO = true
```
Having run tests once to generate expected content, you can make your changes, observe, fix or accept the consequences, and remove the Contentful vise when you're done.

## Meta

* [version] 0.82
* [platforms] Originated under Ubuntu and WinXP with Ruby 1.8.5 and Rails 1.2.3. Small update in Contentful 0.81 for plugin's own test suite to support Rails 2.0.x. Should work across other OS, but touches the file system, so I would like confirmation - please run tests and for real, and tell me! May not work with Ruby 1.8.4 due to an issue with pathname - perhaps fixable, but use at least 1.8.5 for now. Should work with older Rails versions. The select_contentful extension relies on assert_select, which was added in Rails 1.2.
* [author] Anthony Bailey (mailto:mail@anthonybailey.net)
* [etymology] The name of the plug-in is not "Simply Contentful", but simply "Contentful" - I allude, but would not presume.
* [development] http://github.com/anthonybailey/contentful
