# install pypi dependencies
install_pypi_dependencies <- function(package_name){
  tryCatch(
    {
      reticulate::py_install(package_name)
    },
    error=function(cond){
      return(cond)
    }
  )
}

# source python files
source_artemis_py_files <- function(file_path, package_name){
  tryCatch(
    {
      reticulate::source_python(
        system.file(file_path, package=package_name), envir=globalenv()
      )
    },
    error=function(cond){
      error_msg <- sprintf("Encountered error while loading pypi package.\n%s", cond)
      reticulate_last_error <- reticulate::py_last_error()
      if(!is.null(reticulate_last_error)){
        error_msg <- paste0(error_msg, "\n", reticulate_last_error)
      }
      return(error_msg)
    }
  )
}

#Source python functions on load
#' @export
.onLoad <- function(libname, pkgname){
  tryCatch(
    {
        # get the current packages
        py_packages <- reticulate::py_list_packages()
        # install pypi packages
        dependencies <- c("numpy", "pandas")
        for(d in dependencies){
          if(!(d %in% py_packages[['package']])) {
            install_pypi_dependencies(d)
          }
        }

        #load inst/python
        py_file_names <- c("init", "align", "score", "main")
        for(f in py_file_names){
          source_artemis_py_files(
            file_path = file.path("python", f),
            package_name = pkgname
          )
        }
    },
    error=function(cond){
      return(cond)
    }
  )
}
