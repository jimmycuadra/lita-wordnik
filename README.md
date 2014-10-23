# lita-wordnik

[![Build Status](https://travis-ci.org/jimmycuadra/lita-wordnik.png?branch=master)](https://travis-ci.org/jimmycuadra/lita-wordnik)
[![Code Climate](https://codeclimate.com/github/jimmycuadra/lita-wordnik.png)](https://codeclimate.com/github/jimmycuadra/lita-wordnik)
[![Coverage Status](https://coveralls.io/repos/jimmycuadra/lita-wordnik/badge.png)](https://coveralls.io/r/jimmycuadra/lita-wordnik)

**lita-wordnik** is a handler for [Lita](https://github.com/jimmycuadra/lita) that adds dictionary functionality backed by [Wordnik](http://www.wordnik.com/).

## Installation

Add lita-wordnik to your Lita instance's Gemfile:

``` ruby
gem "lita-wordnik"
```

## Configuration

### Required attributes

* `api_key` (String) - Your API key for Wordnik. Register for one at the [Wordnik Developer](http://developer.wordnik.com/) page.

### Example

```
Lita.configure do |config|
  config.handlers.wordnik.api_key = "abc123"
end
```

## Usage

To get the definition for a word:

```
Lita: define WORD
```
To get synonyms for a word:

```
Lita: synonyms WORD
```

or

```
Lita: words like WORD
```

To get antonyms for a word:

```
Lita: antonyms WORD
```

or

```
Lita: words unlike WORD
```

## License

[MIT](http://opensource.org/licenses/MIT)
