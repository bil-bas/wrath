require 'yaml'

class Translation
  def self.translate_yaml_file(filename_in, filename_out)
    data = YAML.load(File.read(filename_in))
    translate_tree(data)
    File.open(filename_out, "w") {|file| file.print data.to_yaml }
  end

  def self.translate_tree(data)
    data.each_pair do |key, value|
      case value
        when String
          data[key] = translate(value)
        when Hash
          translate_tree(value)
      end
    end
  end
end

class Pirate < Translation
  NAME = 'pirate'

  TRANSLATIONS = {
      "achievements" => "deeds",
      "am" => "be",
      "and" => "an'",
      "are" => "be",
      "attention" => "avast",
      "back" => "belay",
      "before" => "afor",
      "ever" => "e'er",
      "is" => "be",
      "my" => "me",
      "never" => "ne'er",
      "no" => "nay",
      "of" => "o'",
      "old" => "ol'",
      "options" => "rigging",
      "player" => "pirate",
      "players" => "pirates",
      "priest" => "buccaneer",
      "priests" => "buccaneers",
      "the" => "th'",
      "to" => "t'",
      "there" => "thar",
      "warning" => "avast",
      "yes" => "aye",
      "you" => "ye",
      "your" => "yer",
  }

  TRANSLATIONS.dup.each_pair do |from, to|
    TRANSLATIONS[from.capitalize] = to.capitalize
  end

  def self.translate(text)
    text.gsub!(/\w+/){|word| TRANSLATIONS[word] || word }
    text.gsub!(/(\w)g([^\w]|$)/ ){|word| "#{$1}'#{$2}" }
    text
  end
end

class PigLatin < Translation
  NAME = 'pig_latin'

  LEADING_CONSONANTS = /^([#{(('a'..'z').to_a - %w[a e i o u]).join}]+)/i

  def self.translate(text)
    text.gsub(/\w{2,}/) do |word|
      if word[-2..-1] == 'ay'
        word
      else
        word =~ LEADING_CONSONANTS
        if $1
          s = "#{$'}#{$1}ay"
          s.capitalize! if word[0] = word[0].upcase
        else
          "#{word}way"
        end
      end
    end
  end
end

class Leet < Translation
  NAME = 'leet'

  TRANSLATIONS = [
      "ABEGILOSTZ",
      "4836110572"
  ]

  def self.translate(text)
    text.upcase!
    text.gsub!(/PRIESTS?/, 'PRIEST' => 'NOOB', 'PRIESTS' => 'NOOBS')
    text.gsub!('CK', 'X')
    text.tr!(*TRANSLATIONS)
    text
  end
end