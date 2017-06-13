-- word is a one word
-- attrs is  set of word attributes
--      verb (Indefinido,Participio,Gerundio,Other)
--      noun (Gender(m,f),Number(s,p),Pronoun(zaimek),Article(rodzajnik))
--      adjective ()
--      adverb ()
CREATE TABLE word_es (id INTEGER PRIMARY KEY,word VARCHAR(255),attrs VARCHAR(10),UNIQUE(word));
CREATE TABLE word_pl (id INTEGER PRIMARY KEY,word VARCHAR(255),attrs VARCHAR(10),UNIQUE(word));
CREATE TABLE word_en (id INTEGER PRIMARY KEY,word VARCHAR(255),attrs VARCHAR(10),UNIQUE(word));
