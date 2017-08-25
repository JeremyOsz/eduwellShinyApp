require(ggmap)
require(rgdal)
require(leaflet)
require(spatial)
require(plyr)
require(RColorBrewer)
require(DBI)

bullying_recent <- read.csv("bullyRecent.csv")

#set LGA
LGA2 <- readRDS("LocalGovtAreas")

#Connect to data base
#REDACTED


conn <- getSqlConnection()
res <- dbListTables(conn)

#read school list (Primary Only)
schoolListQuery <- dbSendQuery(conn, paste("select * from SchoolList", 
                                           "where Type like 'pri%'" ))
schoolList <- dbFetch(schoolListQuery, n=2000)
dbClearResult(dbListResults(conn)[[1]])

#read Enrollments
enollmentQuery <- dbSendQuery(conn, paste("select * from EnrolledStudents where Type like 'pri%'"))
enrolledStudents <- dbFetch(enollmentQuery, n = 2000)
dbClearResult(dbListResults(conn)[[1]])

#join Enrollments and School List
primary2 <- join(enrolledStudents, schoolList, by = "School_Id")

#read Safe Schools
safeSchoolsQuery <- dbSendQuery(conn, paste("select * from SafeSchool"))
safeSchools <- dbFetch(safeSchoolsQuery, n = 2000)
dbClearResult(dbListResults(conn)[[1]])


#bind safe schools

primary2$LGBT <- primary2$School_Id %in% safeSchools$School_Id

#scale total 15 - 70 for icon size

primary2$totalScaled <- scales::rescale(as.numeric(primary2$Total), to = c(25,90))



bins <- c(NA, 0, 2.5, 5, 7.5, 10, 12.5, 15, 17.5, 20,22.5, 25, Inf)
pal <- colorBin(rev(brewer.pal(n = 4, name = "Spectral")), domain = LGA2@data$Indicator, bins = bins)

dbDisconnect(conn)
