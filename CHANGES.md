## [0.6.0](https://github.com/indigobio/abstractivator/compare/v0.5.0...indigobio:v0.6.0) (2016-04-19)

- Added fiber_defer guards for increased flexibility in managing thread-local variables.
  ([1b9226d](https://github.com/indigobio/abstractivator/commit/1b9226d3d525c4293bd90804edb621f967f7d836))


## [0.5.0](https://github.com/indigobio/abstractivator/compare/v0.4.1...indigobio:v0.5.0) (2016-03-30)

- Removed dependency on the 'sourcify' gem.
  ([837ce21](https://github.com/indigobio/abstractivator/commit/837ce2186c157766cc6b9fefc95c03e3c0f34a5a))


## [0.4.1](https://github.com/indigobio/abstractivator/compare/v0.4.0...indigobio:v0.4.1) (2015-11-17)

- Proc.loose_call keyword support
  ([3f93d6a](https://github.com/indigobio/abstractivator/commit/3f93d6a75f06c282a88dfa8926b086d37d0b2294))


## [0.4.0](https://github.com/indigobio/abstractivator/compare/v0.3.1...indigobio:v0.4.0) (2015-11-05)

- Added `Enumerator::unfold` and `Enumerator#memoize`, which memoizes items in a (lazy) `Enumerable`
  ([bb98303](https://github.com/indigobio/abstractivator/commit/bb983037186265a7bf926ca1e347f35927b1401a))


## [0.3.1](https://github.com/indigobio/abstractivator/compare/v0.3.0...indigobio:v0.3.1) (2015-10-16)

- Fixed mongoid_fiber_defer to return the value of the block
  ([f5bfbdd](https://github.com/indigobio/abstractivator/commit/f5bfbdd45a4b31983a03b2f4056064307540844d))


## [0.3.0](https://github.com/indigobio/abstractivator/compare/v0.2.0...indigobio:v0.3.0) (2015-10-15)

- Added mongoid_fiber_defer
  ([c713ddd](https://github.com/indigobio/abstractivator/commit/c713ddd4aa60e4b56465a7d25c89918f0b612610))


## [0.2.0](https://github.com/indigobio/abstractivator/compare/v0.1.1...indigobio:v0.2.0) (2015-10-14)

- Added Abstractivator::FiberDefer. It calls [`EventMachine::defer`](http://www.rubydoc.info/github/eventmachine/eventmachine/EventMachine.defer)
  under the hood and uses fibers to hide asynchrony.
  ([faa83ab](https://github.com/indigobio/abstractivator/commit/faa83abdfb1ecc937183bed5b698d09673ae85ca))


## [0.1.1](https://github.com/indigobio/abstractivator/compare/076419fdadf74dc398e638c8ac7e72d78279457b...indigobio:v0.1.1) (2015-10-14)

- Abstractivator::Event
  ([db10f6c](https://github.com/indigobio/abstractivator/commit/db10f6c3777e01719ec5189a06038f87702c36b0))
- schedule
  ([255bdf0](https://github.com/indigobio/abstractivator/commit/255bdf04817b5892b7cc7cd9b62547aeabee0fed))
- as_json/to_json for Enum
  ([3649cb4](https://github.com/indigobio/abstractivator/commit/3649cb409df4a9aa92ff0a6d7a4a940c862ebd69))
- Simplified Enum implementation
  ([f733588](https://github.com/indigobio/abstractivator/commit/f733588e817f88d8ba79718f65b9ce46a143d51e))
- Fixed bug in Enum.from
  ([76c443d](https://github.com/indigobio/abstractivator/commit/76c443d9df079942d1a953e508e8af1004c4ec87))
- Wrap enum values instead of using SimpleDelegator; adding a value to a hash caused it to lose its enumness
  ([61072a2](https://github.com/indigobio/abstractivator/commit/61072a277f7aba12b1d001f9c82bdf323c69b0e3))
- Improved top level enum implementation
  ([5494244](https://github.com/indigobio/abstractivator/commit/54942448a3a9f243d73829007595ca519a683382))
- define_enum at top-level
  ([0e54d29](https://github.com/indigobio/abstractivator/commit/0e54d295044c865fd1338b6c7dbed4a7f5e89fa4))
- Proc::pipe
  ([6dba7f0](https://github.com/indigobio/abstractivator/commit/6dba7f0349fe5202631f32d6309d4d9e289b1a3c))
- Object#callable?
  ([182a8d5](https://github.com/indigobio/abstractivator/commit/182a8d5d4ed5e561051a3b409bb4d90df6980954))
- When transforming hash and array members, raise a more helpful error if the value is of an unexpected type
  ([f6e78a9](https://github.com/indigobio/abstractivator/commit/f6e78a96f1eeaf3c7d0888f339140a9b847b298b))
- When transforming hash and array members, make the key/index available to the transformer
  ([74e674c](https://github.com/indigobio/abstractivator/commit/74e674c984d3f2066435b0cc05cce8a472b86448))
- tree_map can now delete values
  ([dc48e1b](https://github.com/indigobio/abstractivator/commit/dc48e1bd0ce2dd5a24e32cfaf58a195da2d7547d))
- bugfix: don't add missing keys
  ([f3a4330](https://github.com/indigobio/abstractivator/commit/f3a4330e52db38c3a449abefeb5d51b47cb67532))
- Improved Enumerable#hash_map and Proc::loose_call
  ([151d096](https://github.com/indigobio/abstractivator/commit/151d0960de43d00914d2a3fb0e03301d8c44be9a))
- Added Enum.from
  ([74582e7](https://github.com/indigobio/abstractivator/commit/74582e7f4fb0328fdc4c06a53427061d39d35773))
- Enum values know which enum they belong to
  ([5a6772f](https://github.com/indigobio/abstractivator/commit/5a6772f76cd0153a9226987b797b5b1a49134d54))
- Added array_ext
  ([adcdbc7](https://github.com/indigobio/abstractivator/commit/adcdbc72ef5b8dda2f0a803cecfe0ce2dc3bdeff))
- Proc::compose to_proc's its arguments
  ([94682dd](https://github.com/indigobio/abstractivator/commit/94682dd5883819a47159d52f384aedd5846ad728))
- enum
  ([4eb05b5](https://github.com/indigobio/abstractivator/commit/4eb05b5197ddea782e95558d591b48ba1c626be3))
- proc_ext and enumerable_ext
  ([c2fac9e](https://github.com/indigobio/abstractivator/commit/c2fac9eb1cfc5021f5f466b767cfdd5583ac3650))
- stable_sort
  ([90a24ce](https://github.com/indigobio/abstractivator/commit/90a24ce00007f2e9626ab494dc3c4bfcbbaa720a))
- refactor tweak
  ([b1ff161](https://github.com/indigobio/abstractivator/commit/b1ff161af192d4f64352b15dde84eb815248beae))
- Don't mutate the tree_compare mask when removing :* from set masks
  ([b1484e0](https://github.com/indigobio/abstractivator/commit/b1484e058e77d79c61b519a861dfaf9651044f4a))
- Expanded 'set' use cases for tree_compare
  ([dcc70d0](https://github.com/indigobio/abstractivator/commit/dcc70d05ffd3afc88da0ffb9d426afe6e7c01df9))
- Added a set comparator, SetMask
  ([af394e0](https://github.com/indigobio/abstractivator/commit/af394e0ddff9a9e3431d5c7b852e249d2e57e06b))




