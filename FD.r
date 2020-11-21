#! /usr/bin/env Rscript

#moco_params<-scan("stdin", quiet=TRUE)

args = commandArgs(trailingOnly=TRUE)
moco_params = readLines(args[1])
moco_params = strsplit(moco_params, split = " ")
moco_params = sapply(moco_params, function(x) {
  as.numeric(x[ !(x %in% "")])
})
moco_params = t(moco_params)
colnames(moco_params) = paste0("MOCOparam", 1:ncol(moco_params))
#head(moco_params)

mp = moco_params
mp[, 1:3] = mp[, 1:3] * 50
mp = apply(mp, 2, diff)
mp = rbind(rep(0, 6), mp)
mp = abs(mp)
fd = rowSums(mp)
meanfd = mean(fd)

cat(meanfd)

