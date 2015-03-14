# Process an enwiki*.txt.bz2 file downloaded from Wikipedia to produce the data
# needed for Normalized Web/Wikipedia Distance (NWD).

const DefaultPathToEnwikiFile = "~/tmp/english_wikipedia"
const DefaultEnwikiFileName = "enwiki-20150205-pages-articles-multistream-index.txt.bz2"

const EnwikiFile = if length(ARGS) >= 1
  ARGS[1]
else
  DefaultPathToEnwikiFile * "/" * DefaultEnwikiFileName
end

println("enwiki file: ", EnwikiFile)