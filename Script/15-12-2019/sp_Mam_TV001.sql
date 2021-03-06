USE [DBDinoM]
GO
/****** Object:  StoredProcedure [dbo].[sp_Mam_TV001]    Script Date: 15/12/2019 06:00:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[sp_Mam_TV001] (@tipo int,@tanumi int=-1,@taidCore int=-1,@taproforma int=-1,@taalm int =-1,
@tafdoc date=null,@taven int=-1,@tatven int=-1,
@tafvcr date=null,@taclpr int=-1,@tamon int=-1,@taest int=-1,@taobs nvarchar(50)='',
@tadesc decimal(18,2)=0, @taice decimal(18,2)=0,@tatotal decimal(18,2)=0,
@tauact nvarchar(10)='',@TV0011 TV0011Type ReadOnly,@cliente int=-1 , @almacen int=-1,@producto int=-1,
@panumi int=-1, @TV0014 TV0014Type ReadOnly,@ydNumiUsu int=-1)

AS
BEGIN
	DECLARE @newHora nvarchar(5)
	set @newHora=CONCAT(DATEPART(HOUR,GETDATE()),':',DATEPART(MINUTE,GETDATE()))
	DECLARE @newFecha date
	set @newFecha=GETDATE()
	declare @contabilizo int


	IF @tipo=-1 --ELIMINAR REGISTRO
	BEGIN
		BEGIN TRY
			update TV001 set taest=-1 where tanumi=@tanumi
			DELETE from TV0014   where tg_tanumi=@tanumi
			--DELETE from TV001   where tanumi  =@tanumi
			--DELETE FROM TV0011  WHERE tbtv1numi  =@tanumi;

			set @contabilizo=(select count(*) from BDDiconDinoEco.dbo.TPA001 as a where a.aanumipadre=@tanumi and aatipo=2 and aanumiasiento>0)

			-----Inserto con Estado 3 "Eliminado/Anulado" en BDDiconDinoEco.dbo.TPA001 que servirá para hacer el asiento contable-----		
			if 	@contabilizo=1		
			Begin
				INSERT INTO BDDiconDinoEco.dbo.TPA001
				SELECT aanumipadre, aafecha,2, aacodcliprov, aanomcliprov,
				aaemision,3,aamontototal, aamoneda,6.96, aanscf, -2
				FROM BDDiconDinoEco.dbo.TPA001  WHERE aanumi in (SELECT max(aanumi) FROM BDDiconDinoEco.dbo.TPA001 
				WHERE aanumipadre=@tanumi and aatipo=2)
			End
			else
			Begin	
				INSERT INTO BDDiconDinoEco.dbo.TPA001
				SELECT aanumipadre, aafecha,2, aacodcliprov, aanomcliprov,
				aaemision,3,aamontototal, aamoneda,6.96, aanscf, -1
				FROM BDDiconDinoEco.dbo.TPA001  WHERE aanumi in (SELECT max(aanumi) FROM BDDiconDinoEco.dbo.TPA001 
				WHERE aanumipadre=@tanumi and aatipo=2)
				----Actualizo el aanumiasiento a -1 de los demás registros que corresponden al aanumipadre que se está eliminando----	
				UPDATE BDDiconDinoEco.dbo.TPA001 SET aanumiasiento=-1
				where (aanumipadre=@tanumi and aatipo=2) and (aaestado=1 or aaestado=2)
			End
			select @tanumi as newNumi  --Consultar que hace newNumi
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),-1,@newFecha,@newHora,@tauact)
		END CATCH
	END

	IF @tipo=1 --NUEVO REGISTRO
	BEGIN
		BEGIN TRY 
set @tanumi=IIF((select COUNT(tanumi) from TV001)=0,0,(select MAX(tanumi) from TV001))+1
set @taidCore=IIF((select COUNT(taidcore) from TV001 where Year(TV001.tafdoc)=Year(getDate()))=0,0,(select MAX(tanumi) from TV001 where Year(TV001.tafdoc)=Year(getDate())))+1

			INSERT INTO TV001 VALUES(@tanumi,@taidCore,@taproforma,@taalm,@tafdoc ,@taven  ,@tatven,
			@tafvcr ,@taclpr,@tamon ,@taest  ,@taobs ,@tadesc, @taice ,@tatotal ,@newFecha,@newHora,@tauact)

			----INSERTO EL DETALLE
				INSERT INTO TV0011(tbtv1numi,tbty5prod,tbest ,tbcmin ,tbumin ,tbpbas,tbptot,tbporc ,tbdesc ,tbtotdesc,tbobs, tbpcos,
				tblote ,tbfechaVenc , tbptot2, tbfact ,tbhact ,tbuact )

			SELECT @tanumi,td.tbty5prod,td.tbest ,td.tbcmin ,td.tbumin ,td.tbpbas ,td.tbptot ,td.tbporc,td.tbdesc,td.tbtotdesc,
			td.tbobs, td.tbpcos,td.tblote ,td.tbfechaVenc , td.tbptot2, @newFecha  ,@newHora  ,@tauact    FROM @TV0011 AS td
			where td.estado =0 and  td.tbty5prod >0

			--Insertar Montos
			INSERT INTO TV0014 (tg_tanumi, tgMontBs, tgMontDol, tgMontTare,tgCambioDol)
			SELECT @tanumi,mont.tgMontBs,mont.tgMontDol,mont.tgMontTare,mont.tgCambioDol FROM  @TV0014 mont WHERE mont.tgEstado = 0
			
			select @tanumi as newNumi
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),1,@newFecha,@newHora,@tauact)
		END CATCH
	END
	
	IF @tipo=2--MODIFICACION
	BEGIN
		BEGIN TRY 

			UPDATE TV001 SET taalm=@taalm  ,tafdoc=@tafdoc  ,taven =@taven ,
			tatven =@tatven ,tafvcr =@tafvcr ,taclpr =@taclpr ,tamon =@tamon ,taobs =@taobs ,
			tatotal=@tatotal ,taproforma=@taproforma ,
			tadesc =@tadesc, taice=@taice, tafact =@newFecha,tahact =@newHora ,tauact =@tauact 

					 Where tanumi = @tanumi


		 ----------MODIFICO EL DETALLE DE EQUIPO------------
			--INSERTO LOS NUEVOS
	INSERT INTO TV0011(tbtv1numi,tbty5prod,tbest ,tbcmin ,tbumin ,tbpbas ,tbptot ,tbporc,tbdesc ,tbtotdesc,tbobs, tbpcos,
				tblote ,tbfechaVenc , tbptot2, tbfact ,tbhact ,tbuact )

			SELECT @tanumi,td.tbty5prod,td.tbest ,td.tbcmin ,td.tbumin ,td.tbpbas ,td.tbptot,td.tbporc,td.tbdesc ,td.tbtotdesc ,
			td.tbobs, td.tbpcos,td.tblote ,td.tbfechaVenc , td.tbptot2, @newFecha  ,@newHora  ,@tauact    FROM @TV0011 AS td
			where td.estado =0 and  td.tbty5prod >0

			--MODIFICO LOS REGISTROS
			UPDATE TV0011
			SET tbty5prod =td.tbty5prod ,tbcmin =td.tbcmin ,tbumin =td.tbumin ,tbpbas =td.tbpbas ,tbptot =td.tbptot, tbpcos=td.tbpcos,
			tbptot2=td.tbptot2, tbfact =@newFecha,tbhact =@newHora,tbuact =@tauact,
			tbdesc=td.tbdesc,tbporc=td.tbporc,tbtotdesc=td.tbtotdesc
			FROM TV0011  INNER JOIN @TV0011 AS td
			ON TV0011 .tbnumi    = td.tbnumi  and td.estado=2;

			--ELIMINO LOS REGISTROS
			DELETE FROM TV0011 WHERE tbnumi  in (SELECT td.tbnumi  FROM @TV0011 AS td WHERE td.estado=-1)

			--Insertar Montos
			INSERT INTO TV0014 (tg_tanumi, tgMontBs, tgMontDol, tgMontTare)
			SELECT @tanumi,mont.tgMontBs,mont.tgMontDol,mont.tgMontTare FROM  @TV0014 mont WHERE mont.tgEstado = 0

			--MOdificar MOnto
			UPDATE TV0014
			SET	tgMontBs = mont.tgMontBs, tgMontDol=mont.tgMontDol, tgMontTare=mont.tgMontTare, tgCambioDol = mont.tgCambioDol
			FROM TV0014 
			JOIN @TV0014 AS mont ON TV0014.tgnumi = mont.tgNumi AND mont.tgEstado = 2;		    
			select @tanumi as newNumi
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),2,@newFecha,@newHora,@tauact)
		END CATCH
	END

	IF @tipo=3 --MOSTRaR TODOS
	BEGIN
		BEGIN TRY
		
		select a.tanumi ,a.taalm ,a.tafdoc ,a.taven ,vendedor .yddesc as vendedor ,a.tatven ,a.tafvcr ,a.taclpr,
		cliente.yddesc as cliente ,a.tamon ,IIF(tamon=1,'Boliviano','Dolar') as moneda,a.taest ,a.taobs ,
		a.tadesc, a.taice, a.tafact ,a.tahact ,a.tauact,a.tatotal as total,a.taproforma
		from TV001 as a inner join TY004 as cliente on cliente .ydnumi  =a.taclpr --and a.taest>0 
		inner join TY004 as vendedor on vendedor .ydnumi =taven 
		inner join TV0011 as b on b.tbtv1numi =a.tanumi 
					group by a.tanumi ,a.taalm ,a.tafdoc ,a.taven ,vendedor .yddesc,a.tatven ,a.tafvcr ,a.taclpr,
		cliente.yddesc ,a.tamon ,a.taest ,a.taobs ,
		a.tadesc, a.taice,a.tatotal, a.tafact ,a.tahact ,a.tauact ,a.taproforma
				order by tanumi asc
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END

	IF @tipo=4 --MOSTRaR Detalle
	BEGIN
		BEGIN TRY
		
		
select a.tbnumi ,a.tbtv1numi ,a.tbty5prod, b.yfcprod as codigo, b.yfcbarra, b.yfcdprod1 as producto,a.tbest ,a.tbcmin ,a.tbumin ,Umin .ycdes3 as unidad,
a.tbpbas ,a.tbptot,a.tbporc,a.tbdesc ,a.tbtotdesc,a.tbobs ,
		a.tbpcos,a.tblote ,a.tbfechaVenc , a.tbptot2, a.tbfact ,a.tbhact ,a.tbuact,1 as estado,Cast(null as Image) as img,
		(Sum(inv.iccven )+a.tbcmin ) as stock
		from TV0011 as a inner join TY005 as b on a.tbty5prod =b.yfnumi 
			inner join TY0031 as Umin on Umin .yccod1=1 and Umin .yccod2 =6 and Umin .yccod3 =a.tbumin
			and a.tbtv1numi =@tanumi  -----numiVenta
			inner join TV001 as venta on venta .tanumi =a.tbtv1numi 
			inner join TA001 as almacen on almacen .aanumi  =venta .taalm 
			inner join TA002 as deposito on deposito .abnumi =almacen .aata2dep 
			inner join TI001 as inv on inv.iccprod =a.tbty5prod and inv.icalm =deposito .abnumi 
			
			group by a.tbnumi ,a.tbtv1numi, b.yfcbarra, a.tbty5prod ,b.yfcprod,b.yfcdprod1,a.tbest ,a.tbcmin ,a.tbumin ,Umin .ycdes3 
			,a.tbpbas ,a.tbptot,a.tbporc ,a.tbdesc,a.tbtotdesc,a.tbobs ,
		a.tbpcos,a.tblote ,a.tbfechaVenc , a.tbptot2, a.tbfact ,a.tbhact ,a.tbuact

			order by a.tbnumi  asc
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END

	IF @tipo=5 --MOSTRaR Productos Para Vender
	BEGIN
		BEGIN TRY
		select a.yfnumi ,a.yfcprod, a.yfcbarra, a.yfcdprod1,a.yfcdprod2 ,a.yfgr1,gr1.ycdes3 as grupo1,a.yfgr2
		,gr2.ycdes3 as grupo2 ,a.yfgr3,gr3.ycdes3 as grupo3,a.yfgr4 ,gr4 .ycdes3 as grupo4,a.yfumin ,Umin .ycdes3 as UnidMin
		 ,b.yhprecio, b2.yhprecio as pcos,Sum(inventario .iccven )as stock
		from TY005 as a inner join TY0031 as gr1 on gr1.yccod1 =1 and gr1.yccod2 =1 and gr1.yccod3 =a.yfgr1
		inner join TY0031 as gr2 on gr2.yccod1 =1 and gr2 .yccod2 =2 and gr2.yccod3 =a.yfgr2
		inner join TY0031 as gr3 on gr3.yccod1 =1 and gr3.yccod2 =3 and gr3 .yccod3 =a.yfgr3 
		inner join TY0031 as gr4 on gr4.yccod1 =1 and gr4.yccod2 =4 and gr4.yccod3 =a.yfgr4
			inner join TY0031 as Umin on Umin .yccod1=1 and Umin .yccod2 =6 and Umin .yccod3 =a.yfumin 
		inner join TY0031 as Usup on Usup .yccod1 =1 and Usup .yccod2 =6 and Usup .yccod3 =a.yfusup
		and a.yfap =1 ---Activo o Pasivo Producto
		--Precio venta
		inner join TY007 as b on b.yhprod =a.yfnumi and b.yhalm =@almacen  ----Almacen
		inner join TY004 as c on c.ydcat =b.yhcatpre and c.ydnumi =@cliente  ----Cliente
		--Precio costo
		inner join TY007 as b2 on b2.yhprod =a.yfnumi and b2.yhalm =@almacen  --Almacen
		inner join TY006 as b3 on b2.yhcatpre=b3.ygnumi and b3.ygpcv=0 and b3.ygcod='1' --Estatico
		inner join TA001 as almacen on almacen .aanumi =@almacen 
		inner join TI001 as inventario on inventario .iccprod =a.yfnumi and 
		inventario .icalm =almacen.aata2dep  

	  	group by a.yfnumi ,a.yfcprod, a.yfcbarra, a.yfcdprod1,a.yfcdprod2 ,a.yfgr1,gr1.ycdes3 ,a.yfgr2
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
select b.yfcdprod1 ,a.iclot ,a.icfven  ,a.iccven ,IIF(a.iccven <=b.yfsmin ,1,0)as stockMinimo,IIF(a.icfven <=DateAdd(  day,20,GETDATE ()),1,0) as fechaVencimiento
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
IF @tipo=14   ------obtiene los montos
	BEGIN
		BEGIN TRY
			SELECT
				tgnumi, tg_tanumi, tgMontBs, tgMontDol, tgMontTare, tgCambioDol
			FROM
				TV0014 
			WHERE 
				tg_tanumi = @tanumi
		END TRY
		BEGIN CATCH
			INSERT INTO Tb001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END
IF @tipo= 15 --MOSTRAR CLIENTES SEGUN USUARIO
	BEGIN
		BEGIN TRY
			select 
				a.ydnumi ,
				a.ydcod ,
				a.ydrazonsocial ,
				a.yddesc  ,
				a.yddctnum ,
				a.yddirec 
				,a.ydtelf1 ,
				a.ydfnac ,
				a.ydnumivend ,
				vendedor.yddesc as vendedor,
				a.yddias
			from TY004 as a  
				inner join TY0031 as tipodocumento on tipodocumento .yccod1 =2 and tipodocumento .yccod2 =1 and tipodocumento .yccod3 =a.yddct and a.ydtip =1
				left join TY004 as vendedor on vendedor .ydnumi =a.ydnumivend 
				JOIN ZY003 as usu ON usu.yd_numiVend =vendedor.ydnumi
			Where
				usu.ydnumi = @ydNumiUsu
			order by ydcod 

		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END
IF @tipo=16  ------Verificar Pagos
	BEGIN
		BEGIN TRY
			--Select tdnumi, tdtv12numi, tdnrodoc, tdfechaPago, tdmonto, a.tctv1numi,a.tctotcre
			--From TV00121
			--inner join TV0012 as a on a.tctv1numi=@tanumi
			Select tdnumi, tdtv12numi, tdnrodoc, tdfechaPago, tdmonto, a.tctotcre
			From TV00121
			inner join TV0012 as a on a.tcnumi=tdtv12numi and a.tctv1numi=@tanumi
		END TRY
		BEGIN CATCH
			INSERT INTO Tb001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH

END
IF @tipo=17 --Verificar si la Venta ya fue contabilizada
	BEGIN	
		BEGIN TRY	
			select *
			from BDDiconDinoEco.dbo.TPA001 as a 
			where a.aanumipadre=@tanumi and aatipo=2 and aanumiasiento>0	
		END TRY
		BEGIN CATCH	
			INSERT INTO TB001(banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
			VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@tauact)
		END CATCH
	END
End



