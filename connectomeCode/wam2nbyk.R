library("ElectroGraph")

wam2nbyk <- function(X, names) 
{
	dimensionOfX <- dim(X)
	N <- dimensionOfX[1]

	sources <- c()
	sinks <- c()
	values <- c()

	k <- 1

	for (i in 1:(N-1)) {

	    for (j in (i+1):N  ) {

	    	#print(paste("i is ", i))
		#print(paste("j is ", j))

	    	sources[k] <- names[i]
	    	sinks[k] <- names[j]
		values[k] <- X[i,j]
		
		k <- k + 1
	    }

	}

	bw_graph <- electrograph(cbind(sources,sinks,values))

}

vector2matrix <- function(Y)
{

n_elements = length(Y)
n_regions = (1/2)*( 1 + sqrt( 1 + 8*n_elements))

X = array(0,dim=c(n_regions,n_regions))
k = 1

for (i in 1:(n_regions-1))
{
	for (j in (i+1):n_regions)
	{
		#print(paste("k is ", k, "..."))
		#print(paste("i is ", i, "..."))
		#print(paste("j is ", j, "..."))
		X[i,j] = Y[k]
		X[j,i] = Y[k]
		k = k+1
	}
}

return(X)
}

matrix2vector <- function(X)

{

dims = dim(X)
n_regions = dims[1]

n_elements <- (1/2)*(n_regions)*(n_regions-1)

Y = array(0, dim=c(n_elements, 1))

k = 1

for (i in 1:(n_regions-1))
{
	for (j in (i+1):n_regions)
	{
		Y[k] = X[i,j]
		k = k+1
	}
}

return(Y)
}