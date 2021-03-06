USE [DBDinoM]
GO
/****** Object:  Trigger [dbo].[Tr_Mam_UpdateInsert_Ventae_Insert]    Script Date: 15/12/2019 05:38:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----drop TRIGGER Tr_Mam_UpdateInsert_Compra_Insert
ALTER TRIGGER [dbo].[Tr_Mam_UpdateInsert_Ventae_Insert] ON [dbo].[TV0011]
AFTER INSERT
AS
BEGIN
Declare 
		@tbnumi int,@tbtv1numi int, @tbty5prod int,@tbcmin decimal(18,2),@tbumin int, 
		@ingreso int, @salida int,@obs nvarchar(100),@cantAct decimal(18,2)
		,@maxid1 int,@fact date,@hact nvarchar(5),@uact nvarchar(10),@lcfpag date,@maxid2 int,@deposito int
		,@tblote nvarchar(50),@tbfechavenc date
		,@almacen int,@cliente nvarchar(100)
		set @salida = 4
		set @lcfpag=GETDATE ()
--Declarando el cursor
declare MiCursor Cursor
	for Select a.tbnumi ,a.tbtv1numi ,a.tbty5prod ,a.tbcmin ,a.tbumin,a.tblote ,a.tbfechaVenc    --, a.chhact, a.chuact, b.cpmov, b.cpdesc
				From inserted a where a.tbty5prod  >0  --INNER JOIN TCI001 b ON a.chtmov=b.cpnumi
--Abrir el cursor
open MiCursor
-- Navegar
Fetch MiCursor into @tbnumi,@tbtv1numi,@tbty5prod,@tbcmin,@tbumin,@tblote,@tbfechavenc
while (@@FETCH_STATUS = 0)
begin
set @cliente =(select b.yddesc  from TV001 as a inner join TY004 as b on a.taclpr  =b.ydnumi and b.ydtip =1 and a.tanumi  =@tbtv1numi   )
	
	set @obs = CONCAT(' I ', ' - Venta numiprod:',@tbty5prod,'|',@cliente)
		
		set @obs = CONCAT(@tbtv1numi,'-',@obs)
		set @almacen =(select a.taalm   from TV001 as a where a.tanumi  =@tbtv1numi)
		set @deposito =(Select b.abnumi   from TV001  as a,TA002 as b,TA001 as c where c.aata2depVenta  =b.abnumi 
and a.tanumi  =@tbtv1numi and a.taalm  =c.aanumi )
			if (exists (select TI001.iccprod from TI001 where TI001.iccprod = convert(int, @tbty5prod)
			and TI001 .icalm =@deposito  and TI001.iclot =@tblote and TI001.icfven =@tbfechavenc  ))
			begin 	
				begin try
					begin tran Tr_UpdateTI001
						--Obtener la cantidad actual
					--  set @cantAct = (select TI001.iacant from TI001 where TI001.iacprod = convert(int, @cpcom))
						set @cantAct = (select TI001.iccven  from TI001 where TI001.iccprod  = convert(int, @tbty5prod) and 
						                                  TI001.icalm =@deposito
														 and TI001.iclot =@tblote and TI001.icfven =@tbfechavenc )

						--Actualizar Saldo Inventario
						update TI001 
							set iccven = @cantAct - @tbcmin  
							where TI001.iccprod  = CONVERT(int, @tbty5prod)  and TI001.icalm =@deposito 
							 and TI001.iclot =@tblote and TI001.icfven =@tbfechavenc 

						--Insertar Movimiento
						--Cabecera
						set @maxid1 = iif((select COUNT(a.ibid) from TI002 a) = 0, 0, (select max(a.ibid) from TI002 a))
						set @fact=(SElect a.cafact   from TC001 as a where a.canumi  =@tbtv1numi )
						set @hact =(SElect a.cahact    from TC001 as a where a.canumi =@tbtv1numi )
						set @uact =(SElect a.cauact    from TC001 as a where a.canumi =@tbtv1numi )
						insert into TI002 values(@maxid1+1, @lcfpag ,  @salida, @obs, 3, @deposito,0,0 ,@tbnumi, @fact, @hact, @uact)
						--Detalle
						set @maxid2 = iif((select COUNT(a.icid) from TI0021 a) = 0, 0, (select max(a.icid) from TI0021 a))
						insert into TI0021 values(@maxid2+1, @maxid1+1, CONVERT(int, @tbty5prod ), @tbcmin,
						@tblote ,@tbfechavenc)
					
					commit tran Tr_UpdateTI001
					print concat('Se actualizo el saldo del producto con codigo: ', @tbty5prod)
				end try
				begin catch
					rollback tran Tr_UpdateTI001
					print concat('No se pudo actualizo el saldo del producto con codigo: ', @tbty5prod)
				end catch
			end
			else
			begin
				begin try
					begin tran Tr_InsertTI001
						--Insertar Saldo Inventario
								set @almacen =(select a.taalm   from TV001 as a where a.tanumi  =@tbtv1numi)
					set @deposito =(Select b.abnumi   from TV001  as a,TA002 as b,TA001 as c where c.aata2depVenta  =b.abnumi 
and a.tanumi  =@tbtv1numi and a.taalm  =c.aanumi )
						Insert into TI001 values(@deposito ,CONVERT(int, @tbty5prod), -@tbcmin, @tbumin,
						@tblote ,@tbfechavenc)
			
						--Insertar Movimiento
						--Cabecera
						set @maxid1 = iif((select COUNT(a.ibid) from TI002 a) = 0, 0, (select max(a.ibid) from TI002 a))

						insert into TI002 values(@maxid1+1, @lcfpag ,  @salida, @obs, 3, @deposito ,0,0  , @tbnumi, @fact, @hact, @uact)

						--Detalle
						--set @maxid2 = (select max(a.icid) from TI0021 a)
						set @maxid2 = iif((select COUNT(a.icid) from TI0021 a) = 0, 0, (select max(a.icid) from TI0021 a))
						insert into TI0021 values(@maxid2+1, @maxid1+1, CONVERT(int, @tbty5prod), @tbcmin,@tblote ,@tbfechavenc)
					commit tran Tr_InsertTI001
					print concat('Se grabo el saldo del producto con codigo: ', @tbty5prod)
				end try
				begin catch
					rollback tran Tr_InsertTI001
					print concat('No se grabo el saldo del producto con codigo: ', @tbty5prod)
				end catch
			end
		
	Fetch MiCursor into @tbnumi,@tbtv1numi,@tbty5prod,@tbcmin,@tbumin,@tblote,@tbfechavenc
end

--Cerrar el Cursor
close MiCursor
--Liberar la memoria
deallocate MiCursor
END
