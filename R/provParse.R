# provParse.R Orenna Brand & Joe Wonsil

# The environment that will store the list of data frames
# that have the prov data from the json
prov.env <- new.env(parent = emptyenv())
prov.env$prov.df <- NULL

# Generalized parser
parse.general <- function(requested, m.list) {
  
  # Constructs pattern to match to using the grep function.
  grep.arg <- paste("^", requested, "[[:digit:]]", sep = "")
  
  # Using the pattern to pull out only the requested
  # nodes/edges from the master list.
  # This list had data stored in rows not columns
  nodes <- m.list[grep(grep.arg, names(m.list))]
  
  nodes.df <- data.frame(NULL)
  
  if(length(nodes) > 0) {
    # The num of columns are stored in each row in the list
    # Pull out how many columns so we can index through each
    # row and receive the columns
    col.length <- 1:length(nodes[[1]])
    
    # Use index nums to pull out each column so they are
    # no longer stored as rows but columns
    col.list <- lapply(col.length, function(x) {
      return(mapply(`[`, nodes, x))
    })
    
    # To each column, replace the string "NA" with
    # an actual R value of NA, the extract the column 
    # as a vector to coerce into one type
    node.vec <- lapply(col.length, function(x) {
      col <- mapply(`[`, nodes, x)
      col[col=="NA"] <- NA
      return(mapply(`[`, col, 1))
    })
    
    # Convert the data frame, we do not have factors
    # in data so keep them as strings
    nodes.df <- data.frame(node.vec, stringsAsFactors = F)
    colnames(nodes.df) <- names(nodes[[1]])
    rownames(nodes.df) <- names(nodes)
  }
  
  # Combine into a single data frame.
  return(nodes.df)
}

# Environment parser
parse.envi <- function(m.list) {
  
  env <- m.list$environment
  
  # Remove nested lists which are parsed in a different
  # function
  env <- env[-which(names(env) == "sourcedScripts")]
  env <- env[-which(names(env) == "sourcedScriptTimeStamps")]
  
  # Swap rows and columns for clarity and apply name the column
  environment <- t(as.data.frame(env))
  environment <- data.frame(environment, stringsAsFactors = F)
  colnames(environment) <- c("value")
  
  return(environment)
}

# Libraries parser
parse.libs <- function(m.list) {
  # Use the general function, however it will 
  # add unneeded columns
  libraries <- parse.general("l", m.list)
  
  # Pull out two columns of info wanted
  libraries <- libraries[,c("name", "version")]
  
  
  
  return(libraries)
}

# Source scripts parser
parse.scripts <- function(m.list) {
  
  # The source scripts are nested in the environment object
  env <- m.list$environment
  
  # Grab the script names
  scripts <- env$`rdt:sourcedScripts`
  
  # Append the script time stamps to the end
  scripts <- as.data.frame(cbind(scripts, env$`rdt:sourcedScriptTimeStamps`))
  
  # If there are scripts, append names to the data frame
  if (length(scripts) > 0) names(scripts) <- c("scripts", "timestamps")
  
  return(scripts)
}

## ==Simple wrapper functions for calling data frames==##

#' Access functions that will retrieve information that has been parsed from the prov.json file.
#' The function prov.parse MUST be run before using these functions.
#' 
#' @return The data frame of the requested information.
#'
#' @examples
#' get.proc.nodes()
#' get.data.nodes()
#' get.func.nodes()
#' get.proc.proc()
#' get.data.proc()
#' get.proc.data()
#' get.func.proc()
#' get.func.lib()
#' get.libs()
#' get.scripts()
#' get.environment()
#' get.all.df()
#' 
#' @name access
#' 
NULL
#> NULL

#' @rdname access
#' @export
get.environment <- function() {
  return(if (!is.null(prov.env$prov.df)) {
    prov.env$prov.df[["envi"]]
  } else {
    stop("No provenance parsed yet, try running prov.parse first")
  })
}

#' @rdname access
get.proc.nodes <- function() {
  return(if (!is.null(prov.env$prov.df)) {
    prov.env$prov.df[["procNodes"]]
  } else {
    stop("No provenance parsed yet, try running prov.parse first")
  })
}

#' @rdname access
get.data.nodes <- function() {
  return(if (!is.null(prov.env$prov.df)) {
    prov.env$prov.df[["dataNodes"]]
  } else {
    stop("No provenance parsed yet, try running prov.parse first")
  })
}

#' @rdname access
get.func.nodes <- function() {
  return(if (!is.null(prov.env$prov.df)) {
    prov.env$prov.df[["funcNodes"]]
  } else {
    stop("No provenance parsed yet, try running prov.parse first")
  })
}

#' @rdname access
get.proc.proc <- function() {
  return(if (!is.null(prov.env$prov.df)) {
    prov.env$prov.df[["procProcEdges"]]
  } else {
    stop("No provenance parsed yet, try running prov.parse first")
  })
}

#' @rdname access
get.data.proc <- function() {
  return(if (!is.null(prov.env$prov.df)) {
    prov.env$prov.df[["dataProcEdges"]]
  } else {
    stop("No provenance parsed yet, try running prov.parse first")
  })
}

#' @rdname access
get.proc.data <- function() {
  return(if (!is.null(prov.env$prov.df)) {
    prov.env$prov.df[["procDataEdges"]]
  } else {
    stop("No provenance parsed yet, try running prov.parse first")
  })
}

#' @rdname access
get.func.proc <- function() {
  return(if (!is.null(prov.env$prov.df)) {
    prov.env$prov.df[["funcProcEdges"]]
  } else {
    stop("No provenance parsed yet, try running prov.parse first")
  })
}

#' @rdname access
get.func.lib <- function() {
  return(if (!is.null(prov.env$prov.df)) {
    prov.env$prov.df[["funcLibEdges"]]
  } else {
    stop("No provenance parsed yet, try running prov.parse first")
  })
}

#' @rdname access
get.libs <- function() {
  return(if (!is.null(prov.env$prov.df)) {
    prov.env$prov.df[["libs"]]
  } else {
    stop("No provenance parsed yet, try running prov.parse first")
  })
}

#' @rdname access
get.scripts <- function() {
  return(if (!is.null(prov.env$prov.df)) {
    prov.env$prov.df[["scripts"]]
  } else {
    stop("No provenance parsed yet, try running prov.parse first")
  })
}

#' @rdname access
#' @export
get.all.df <- function() {
  return(if (!is.null(prov.env$prov.df)) {
    prov.env$prov.df
  } else {
    stop("No provenance parsed yet, try running prov.parse first")
  })
}

## ====##

#' Parses the information in a prov.json file and makes it available to be 
#' when accessed through the access functions. 
#'
#' @param filename A path to a json file that has been generated by RDataTracker
#' @return Does not return a value, but opens up the use of the access functions
#' @export
#' @examples
#' prov.parse("ddg.json")
prov.parse <- function(filename) {
  library("jsonlite")
  
  # Removing 'rdt:' prefix for legibility of data.
  prov <- readLines(filename)
  prov <- gsub("rdt:", "", prov)
  prov <- gsub("prov:", "", prov)
  
  # Converting to an R-useable data structure.
  prov.data <- fromJSON(prov)
  
  # Creating the master list by unlisting the nodes/edges.
  master.list <- unlist(prov.data, recursive = F)
  
  # This removes the appended prefixes created by unlisting.
  # This leaves the nodes with their original names.
  names(master.list) <- gsub("^.*\\.", "", names(master.list))
  
  
  # These nodes cannot be parsed with the generalized function.
  # Therefore they are done separately and appended later.
  envi.df <- parse.envi(master.list)
  lib.df <- parse.libs(master.list)
  scr.df <- parse.scripts(master.list)
  
  # This list represents the characters codes for the different
  # possible objects.
  obj.chars <- c("p", "d", "f", "pp", "pd", "dp", "fp", "m")
  
  # Utilizes char codes to produce the list of data frames.
  prov.df <- lapply(obj.chars, parse.general, m.list = master.list)
  
  names(prov.df) <- c("procNodes", "dataNodes", "funcNodes", 
    "procProcEdges", "procDataEdges", "dataProcEdges", "funcProcEdges", 
    "funcLibEdges")
  
  # Appending hard-coded data to list of data frames.
  prov.df[["envi"]] <- envi.df
  prov.df[["libs"]] <- lib.df
  prov.df[["scripts"]] <- scr.df
  
  assign("prov.df", prov.df, envir = prov.env)
}

