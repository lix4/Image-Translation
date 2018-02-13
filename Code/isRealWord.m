function [tOrf] = isRealWord(word2Translate)
tOrf = 0;
if (strcmp(word2Translate, 'world'))
    tOrf = 1;
end    