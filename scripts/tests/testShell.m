function answer = testShell(number, word, outfile)
  %%  This is just a function to test the matlab_batcher.
  %%  It will write the word number times in outfile.


  fileid = fopen(outfile);
  format = '%%';

N=number;


save('thisfilemat', 'word');    

  end
