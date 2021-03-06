USE [DBDinoM]
GO
/****** Object:  StoredProcedure [dbo].[sp_Marco_TV001]    Script Date: 15/12/2019 06:21:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--drop PROCEDURE sp_Mam_TV001
ALTER PROCEDURE [dbo].[sp_Marco_TV001] (@tipo int,@tanumi int=-1,@taidCore int=-1,@taproforma int=-1,@taalm int =-1,
@tafdoc date=null,@taven int=-1,@tatven int=-1,
@tafvcr date=null,@taclpr int=-1,@tamon int=-1,@taest int=-1,@taobs nvarchar(50)='',
@tadesc decimal(18,2)=0, @taice decimal(18,2)=0,@tatotal decimal(18,2)=0,
@tauact nvarchar(10)='',@cliente int=-1 , @almacen int=-1,@producto int=-1,
@panumi int=-1)

AS
BEGIN
	DECLARE @newHora nvarchar(5)
	set @newHora=CONCAT(DATEPART(HOUR,GETDATE()),':',DATEPART(MINUTE,GETDATE()))

	DECLARE @newFecha date
	set @newFecha=GETDATE()


	IF @tipo=5 --MOSTRaR Productos Para Vender
	BEGIN
		BEGIN TRY
	
		select a.yfnumi ,a.yfcprod, a.yfcbarra, a.yfcdprod1,a.yfcdprod2 ,a.yfgr1,gr1.ycdes3 as grupo1,a.yfgr2
		,gr2.ycdes3 as grupo2 ,a.yfgr3,gr3.ycdes3 as grupo3,a.yfgr4 ,gr4 .ycdes3 as grupo4,a.yfumin ,Umin .ycdes3 as UnidMin
		 ,b.yhprecio, b2.yhprecio as pcos,Sum(inventario .iccven )as stock,IIF( (Sum(inventario .iccven )<a.yfsmin),1,0) as validacion
		from TY005 as a inner join TY0031 as gr1 on gr1.yccod1 =1 and gr1.yccod2 =1 and gr1.yccod3 =a.yfgr1
		inner join TY0031 as gr2 on gr2.yccod1 =1 and gr2 .yccod2 =2 and gr2.yccod3 =a.yfgr2
		inner join TY0031 as gr3 on gr3.yccod1 =1 and gr3.yccod2 =3 and gr3 .yccod3 =a.yfgr3 
		inner join TY0031 as gr4 on gr4.yccod1 =1 and gr4.yccod2 =4 and gr4.yccod3 =a.yfgr4
		inner join TY0031 as Umin on Umin .yccod1=1 and Umin .yccod2 =6 and Umin .yccod3 =a.yfumin 
		and a.yfap =1 ---Activo o Pasivo Producto
		--Precio venta
		inner join TY007 as b on b.yhprod =a.yfnumi and b.yhalm =@almacen  ----Almacen
		inner join TY004 as c on c.ydcat =b.yhcatpre and c.ydnumi =@cliente  ----Cliente
		--Precio costo
		inner join TY007 as b2 on b2.yhprod =a.yfnumi and b2.yhalm =@almacen and b2.yhcatpre=1099   --Almacen
		inner join TA001 as almacen on almacen .aanumi =@almacen
		inner join TI001 as inventario on inventario .iccprod =a.yfnumi and 
		inventario .icalm =almacen .aata2depVenta 

	  	group by a.yfnumi ,a.yfcprod, a.yfcbarra, a.yfcdprod1,a.yfcdprod2 ,a.yfsmin,a.yfgr1,gr1.ycdes3 ,a.yfgr2
		,gr2.ycdes3 ,a.yfgr3,gr3.ycdes3 ,a.yfgr4 ,gr4 .ycdes3,a.yfumin ,Umin .ycdes3 
		 ,b.yhprecio, b2.yhprecio
		 order by a.yfnumi  asc 
	
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END

	IF @tipo=6 --MOSTRaR Clientes
	BEGIN
		BEGIN TRY
	select a.ydnumi ,a.ydcod ,a.ydrazonsocial ,a.yddesc  ,a.yddctnum ,a.yddirec 
		,a.ydtelf1 ,a.ydfnac ,a.ydnumivend ,vendedor.yddesc as vendedor, a.yddias
		from TY004 as a inner join TY0031 as tipodocumento on
		 tipodocumento .yccod1 =2 and tipodocumento .yccod2 =1 and tipodocumento .yccod3 =a.yddct and a.ydtip =1
		 left join TY004 as vendedor on vendedor .ydnumi =a.ydnumivend 
				order by ydcod 
				END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END
	IF @tipo=7 --MOSTRaR Vendedores
	BEGIN
		BEGIN TRY
	select a.ydnumi ,a.ydcod ,a.yddesc  ,a.yddctnum ,a.yddirec 
		,a.ydtelf1 ,a.ydfnac 
		from TY004 as a inner join TY0031 as tipodocumento on
		 tipodocumento .yccod1 =2 and tipodocumento .yccod2 =1 and tipodocumento .yccod3 =a.yddct and a.ydtip =2
				order by ydcod 
		
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END

IF @tipo=8 --MOSTRaR Vendedores
	BEGIN
		BEGIN TRY
select b.yfcdprod1 ,a.iclot ,a.icfven  ,a.iccven 
from TI001 as a ,TY005 as b,TA002 as deposito ,TA001 as almacen
where a.iccprod =@producto 
and a.iccven >0 and a.iccprod =b.yfnumi 
and deposito .abnumi =almacen .aata2depVenta  and almacen .aanumi =@almacen --Almcaen
and a.icalm =deposito .abnumi 
order by a.icfven asc
		
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END
IF @tipo=9 --MOSTRaR Productos Para Vender
	BEGIN
		BEGIN TRY



		 select a.yfnumi ,a.yfcprod, a.yfcbarra, a.yfcdprod1,a.yfcdprod2 ,a.yfgr1,gr1.ycdes3 as grupo1,a.yfgr2
		,gr2.ycdes3 as grupo2 ,a.yfgr3,gr3.ycdes3 as grupo3,a.yfgr4 ,gr4 .ycdes3 as grupo4,a.yfumin ,Umin .ycdes3 as UnidMin
		 ,(	select b.yhprecio   from  TY007 as b inner join TY004 as c on c.ydcat =b.yhcatpre and c.ydnumi =@cliente
		and b.yhprod =a.yfnumi and b.yhalm =@almacen  ) yhprecio,(select b2.yhprecio  from  TY007 as b2 inner join TY006 as b3 on b2.yhcatpre=b3.ygnumi and 
		 b2.yhprod =a.yfnumi and b2.yhalm =@almacen and b3.ygpcv=0 and b3.ygcod='1' )  as pcos,  (select ti.cant from Vr_Stock_Total as ti where ti.yfnumi =a.yfnumi and ti.icalm =@almacen)as stock
		from TY005 as a inner join TY0031 as gr1 on gr1.yccod1 =1 and gr1.yccod2 =1 and gr1.yccod3 =a.yfgr1
	
		inner join TY0031 as gr2 on gr2.yccod1 =1 and gr2 .yccod2 =2 and gr2.yccod3 =a.yfgr2
		inner join TY0031 as gr3 on gr3.yccod1 =1 and gr3.yccod2 =3 and gr3 .yccod3 =a.yfgr3 
		inner join TY0031 as gr4 on gr4.yccod1 =1 and gr4.yccod2 =4 and gr4.yccod3 =a.yfgr4
			inner join TY0031 as Umin on Umin .yccod1=1 and Umin .yccod2 =6 and Umin .yccod3 =a.yfumin 
		inner join TY0031 as Usup on Usup .yccod1 =1 and Usup .yccod2 =6 and Usup .yccod3 =a.yfusup
		and a.yfap =1 ---Activo o Pasivo Producto
		
	
	
		 order by a.yfnumi  asc 

		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END

IF @tipo=10 --IMPRIMIR NOTA DE VENTA
	BEGIN
		BEGIN TRY
select venta.tanumi ,FORMAT (venta.tafdoc , 'dd-MM-yyyy')as FechaVenta,cliente .ydnumi as numicliente,cliente .yddesc as cliente,cliente .yddirec ,
cliente.yddctnum as ci,cliente .ydtelf1 as telefono,vendedor .ydnumi  as numivendedor , vendedor .yddesc as vendedor,
almacen .aanumi as numialmacen,almacen .aabdes as almacen,IIF(venta.tatven=0,Concat('Fecha Venc: ',FORMAT (venta.tafvcr, 'dd-MM-yyyy') ),'') as FechaCredito,
detalle .tbcmin as cantidad,detalle.tbty5prod as codProducto,producto .yfcdprod1 as producto
,gr2.ycdes3 as Presentacion,gr3 .ycdes3 as pa,detalle .tbpbas as unitario,detalle .tbptot as subtotal,
detalle .tbdesc as Descuento,detalle .tbtotdesc as Total,detalle .tblote as lote,FORMAT (detalle .tbfechaVenc, 'dd-MM-yyyy') as FechaVenc,cliente.
ydrazonsocial as RazonSocial,producto.yfcprod as Cflex,producto.yfvsup as Conversion
from TV001 as venta inner join TV0011 as detalle on venta.tanumi=detalle .tbtv1numi 
inner join TY004 as cliente on venta.taclpr =cliente.ydnumi 
inner join TA001 as almacen on almacen .aanumi =venta .taalm 
inner join TY004 as vendedor on vendedor .ydnumi =venta.taven
inner join TY005 as producto on producto .yfnumi =detalle .tbty5prod  
inner join TY0031 as gr2 on gr2.yccod1 =1 and gr2 .yccod2 =4 and gr2.yccod3 =producto .yfgr4
inner join TY0031 as gr3 on gr3.yccod1 =1 and gr3.yccod2 =5 and gr3 .yccod3 =producto .yfMed 
where venta.tanumi =@tanumi 
		
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END


	IF @tipo=11 --ListarProformas
	BEGIN
		BEGIN TRY

select a.panumi ,a.pafdoc ,a.paven ,vendedor .yddesc as vendedor,a.paclpr,
		cliente.yddesc as cliente,a.patotal as total,a.paalm 
		from TP001 as a inner join TY004 as cliente on cliente .ydnumi  =a.paclpr and a.paest>0 
		inner join TY004 as vendedor on vendedor .ydnumi =paven 
		inner join TP0011 as b on b.pbtp1numi =a.panumi 
		where a.panumi not in(select isnull(k.taproforma,0)   from TV001 as k)
		------Taest=Aqui guardare el numi de la proforma si se hiciera venta con proforma
					group by a.panumi ,a.paalm ,a.pafdoc ,a.paven ,vendedor .yddesc,a.paclpr,
		cliente.yddesc ,a.pamon ,a.paest ,a.paobs ,
		a.padesc,a.patotal, a.pafact ,a.pahact ,a.pauact 
		
				order by panumi asc
				END TRY
		BEGIN CATCH
			INSERT INTO Tb001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END


	IF @tipo=12 
	BEGIN
		BEGIN TRY

select a.pbnumi ,a.pbtp1numi ,a.pbty5prod ,b.yfcdprod1 as producto ,a.pbcmin ,a.pbumin ,Umin .ycdes3 as unidad,
a.pbpbas ,a.pbptot,a.pbporc,a.pbdesc ,a.pbtotdesc,
		(Sum(inv.iccven )+a.pbcmin ) as stock,precio.yhprecio as pcosto
		from TP0011 as a inner join TY005 as b on a.pbty5prod =b.yfnumi 
			inner join TY0031 as Umin on Umin .yccod1=1 and Umin .yccod2 =6 and Umin .yccod3 =a.pbumin
			and a.pbtp1numi =@panumi -----numiventa
			inner join TP001 as venta on venta .panumi =a.pbtp1numi 
			inner join TA001 as almacen on almacen .aanumi  =venta .paalm 
			inner join tA002 as deposito on deposito .abnumi =almacen.aata2dep 
			inner join TI001 as inv on inv.iccprod =a.pbty5prod and inv.icalm =deposito .abnumi 

			inner join TY007 as precio on precio.yhprod =a.pbty5prod  and precio.yhalm =venta .paalm   ----Almacen
			inner join TY006 as b3 on precio.yhcatpre=b3.ygnumi and b3.ygpcv=0 and b3.ygcod='1' --Estatico
			
			group by a.pbnumi,a.pbtp1numi  ,a.pbty5prod ,b.yfcdprod1 ,a.pbest ,a.pbcmin ,a.pbumin ,Umin .ycdes3 
			,a.pbpbas ,a.pbptot,a.pbporc ,a.pbdesc,a.pbtotdesc, a.pbfact ,a.pbhact ,a.pbuact,precio.yhprecio

			order by a.pbnumi  asc
				END TRY
		BEGIN CATCH
			INSERT INTO Tb001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END
IF @tipo=13   ------REPORTE DE FACTURACION
	BEGIN
		BEGIN TRY
SELECT DAY(venta.tafdoc) AS dia, MONTH(venta.tafdoc) AS Mes, YEAR(venta.tafdoc) AS Ano, cliente.yddesc AS cliente, detalle.tbcmin AS cantidad, producto.yfcdprod1 AS producto, gr2.ycdes3 AS Presentacion, gr3.ycdes3 AS pa, 
                  detalle.tbpbas AS unitario, detalle.tbtotdesc AS Total, '123456789' AS nit
FROM     dbo.TV001 AS venta INNER JOIN
                  dbo.TV0011 AS detalle ON venta.tanumi = detalle.tbtv1numi INNER JOIN
                  dbo.TY004 AS cliente ON venta.taclpr = cliente.ydnumi INNER JOIN
                  dbo.TA001 AS almacen ON almacen.aanumi = venta.taalm INNER JOIN
                  dbo.TY004 AS vendedor ON vendedor.ydnumi = venta.taven INNER JOIN
                  dbo.TY005 AS producto ON producto.yfnumi = detalle.tbty5prod INNER JOIN
                  dbo.TY0031 AS gr2 ON gr2.yccod1 = 1 AND gr2.yccod2 = 4 AND gr2.yccod3 = producto.yfgr4 INNER JOIN
                  dbo.TY0031 AS gr3 ON gr3.yccod1 = 1 AND gr3.yccod2 = 5 AND gr3.yccod3 = producto.yfMed
WHERE  (venta.tanumi = @tanumi)
				END TRY
		BEGIN CATCH
			INSERT INTO Tb001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END
End


