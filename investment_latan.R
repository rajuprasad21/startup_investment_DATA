#=======================================Obtención de datos=======================================
#Escrapper library
library(rvest)
#Obtener la data de la web
url<-"https://database.contxto.com/latest-investments"
pagina_web<-read_html(url)
selector<-"#table"
node<-html_node(pagina_web,selector)
table<-html_table(node)
startups_investment<-table[,-1]
write.csv(startups_investment,"/Users/carlos97gr/Documents/R/startups_latin_investment.csv")#Remplaza tu ruta aca
#========================================Limpieza de los datos====================================
#--------Revisión de datos almacenados--------
str(startups_investment) 
#------------------Amount---------------------:
#Volverlo numerico con datos de monto equivalentes
startups_investment$Amount<-gsub("\\$","",startups_investment$Amount) #doble slash invertido para poder eliminar simbolos
startups_investment$Amount<-gsub("Undisclosed",NA,startups_investment$Amount)
startups_investment$Amount<-gsub("N/A",NA,startups_investment$Amount)
startups_investment$Amount<-gsub("Unknown",NA,startups_investment$Amount)
startups_investment$Amount<-gsub("UND",NA,startups_investment$Amount)
startups_investment$Amount<-gsub("M","",startups_investment$Amount)
#Convertimos los miles a millones para mantener una sola unidad
amount_K<-grep("K", startups_investment$Amount)
amount_in_K<-startups_investment$Amount[amount_K]
#Borramos el caracter, luego convertimos el dato a numérico y lo volvemos a millones
#Un millon son mil miles
amount_k_clean<-(as.numeric(gsub("K","",amount_in_K)))/1000
#Remplazamos los nuevos valores en el dataset
startups_investment$Amount[amount_K] <- amount_k_clean
#Convertimos los datos a numericos
startups_investment$Amount<-as.numeric(startups_investment$Amount)
#----------Industry---------------------------
startups_investment$Industry<-gsub(" ","",startups_investment$Industry)
startups_investment$Industry<-gsub("N/A",NA,startups_investment$Industry)
#----------Investors--------------------------
startups_investment$Investors<-gsub(" ","",startups_investment$Investors)
startups_investment$Investors<-gsub("N/A",NA,startups_investment$Investors)
startups_investment$Investors<-gsub("Undisclosed",NA,startups_investment$Investors)
#----------Location---------------------------
#Para la localización separemos la ciudad del país en columnas independientes nos ayudaremos de algunas librerias
library(stringr)
str(startups_investment$Location)
#Separamos para tener ciudad y pais en columnas diferentes
location<-str_split_fixed(startups_investment$Location,",",n=2)
location<-as.data.frame(location)
colnames(location)<-c("Ciudad","Pais")
#Remplazamos columnas vacias por NA
location[location=='']<-NA
#Revisamos si los datos siguen como Char
str(location)
#Devolvemos a char los datos
location$Ciudad<-as.character(location$Ciudad)
location$Pais<-as.character(location$Pais)
#Remplazamos la Ciudad en Pais en los registros donde Pais no tenga registro
location$Pais[is.na(location$Pais)]<-location$Ciudad[is.na(location$Pais)]
#Luego remplazamos la ciudades cuyo pais sea el mismo nombre
location$Ciudad[location$Pais==location$Ciudad]<-"Desconocida"
#Limpiamos pais ya que quedo con un espacio adelante luego de separar
location$Pais<-gsub(" ","",location$Industry)
startups_investment<-cbind(startups_investment,location)
startups_investment<-startups_investment[,-3]
startups_investment$Pais<-gsub(" ","",startups_investment$Pais)

startups_investment_clean<-startups_investment
write.csv(startups_investment_clean,"/Users/carlos97gr/Documents/R/startups_latin_investment_clean.csv")
#Remplaza tu ruta aca


