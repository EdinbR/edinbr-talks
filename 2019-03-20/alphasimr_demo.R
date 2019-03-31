
library(AlphaSimR)
library(ggplot2)

## Generate founder chromsomes

FOUNDERPOP <- runMacs(nInd = 1000,
                      nChr = 10,
                      segSites = 5000,
                      inbred = FALSE,
                      species = "GENERIC")


## Simulation parameters

SIMPARAM <- SimParam$new(FOUNDERPOP)
SIMPARAM$addTraitA(nQtlPerChr = 100,
                   mean = 100,
                   var = 10)
SIMPARAM$addSnpChip(nSnpPerChr = 1000)
SIMPARAM$setGender("yes_sys")


## Founding population

pop <- newPop(FOUNDERPOP,
              simParam = SIMPARAM)

pop <- setPheno(pop,
                varE = 20,
                simParam = SIMPARAM)


## Breeding

print("Breeding")
breeding <- vector(length = 11, mode = "list")
breeding[[1]] <- pop

for (i in 2:11) {
    print(i)
    sires <- selectInd(pop = breeding[[i - 1]],
                       gender = "M",
                       nInd = 25,
                       trait = 1,
                       use = "pheno",
                       simParam = SIMPARAM)

    dams <- selectInd(pop = breeding[[i - 1]],
                      nInd = 500,
                      gender = "F",
                      trait = 1,
                      use = "pheno",
                      simParam = SIMPARAM)

    breeding[[i]] <- randCross2(males = sires,
                                females = dams,
                                nCrosses = 500,
                                nProgeny = 10,
                                simParam = SIMPARAM)
    breeding[[i]] <- setPheno(breeding[[i]],
                              varE = 20,
                              simParam = SIMPARAM)
}






## CHEATING

mean_g <- unlist(lapply(breeding, meanG))
sd_g <- sqrt(unlist(lapply(breeding, varG)))


plot_gain <- qplot(x = 1:11, y = mean_g, ymin = mean_g - sd_g, ymax = mean_g + sd_g, geom = "pointrange")



start_geno <- pullQtlGeno(breeding[[1]], simParam = SIMPARAM)
start_freq <- colSums(start_geno)/(2 * nrow(start_geno))


end_geno <- pullQtlGeno(breeding[[11]], simParam = SIMPARAM)
end_freq <- colSums(end_geno)/(2 * nrow(end_geno))
