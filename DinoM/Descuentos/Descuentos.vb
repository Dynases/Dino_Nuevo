
Imports Logica.AccesoLogica
Imports Janus.Windows.GridEX
Imports DevComponents.DotNetBar
Imports DevComponents.DotNetBar.Controls
Public Class Descuentos
    Dim _inter As Integer = 0
#Region "Variables Globales"

    Dim _Pos As Integer
    Dim _Nuevo As Boolean
    Dim _Dsencabezado As DataSet

    Dim _BindingSource As BindingSource
    Dim _Modificar As Boolean

    Dim modif As Boolean = True

    Public _nameButton As String
    Public _tab As SuperTabItem
    Public _modulo As SideNavItem

    Dim dtPreciosDesc As New DataTable

#End Region
    Private Sub _PIniciarTodo()

        L_prAbrirConexion()


        Me.Text = " P R E C I O S  -  D E S C U E N T O S "
        'Me.WindowState = FormWindowState.Maximized
        _prCargarProductos()

        btnGrabar.Visible = False
        btnNuevo.Visible = True

        tbDesde.IsInputReadOnly = True
        tbHasta.IsInputReadOnly = True
        tbPrecio.IsInputReadOnly = True

    End Sub
    Private Sub _prCargarProductos()
        Dim dt As New DataTable
        dt = L_fnListarProductosDescuentos()
        grProducto.DataSource = dt
        grProducto.RetrieveStructure()
        grProducto.AlternatingColors = True
        '      a.tbnumi ,a.tbtv1numi ,a.tbty5prod ,b.yfcdprod1 as producto,a.tbest ,a.tbcmin ,a.tbumin ,Umin .ycdes3 as unidad,a.tbpbas ,a.tbptot,a.tbdesc ,a.tbobs ,
        'a.tbfact ,a.tbhact ,a.tbuact

        With grProducto.RootTable.Columns("ProductoId")
            .Width = 100
            .Caption = "Id"
            .Visible = True
        End With

        With grProducto.RootTable.Columns("CodigoExterno")
            .Caption = "Cod.Externo"
            .Width = 90
            .Visible = True
        End With
        With grProducto.RootTable.Columns("CodigoBarra")
            .Caption = "Cod.Barra"
            .Width = 90
            .Visible = True
        End With
        With grProducto.RootTable.Columns("NombreProducto")
            .Caption = "PRODUCTOS"
            .Width = 250
            .Visible = True
        End With

        With grProducto
            .GroupByBoxVisible = False
            'diseño de la grilla
            .VisualStyle = VisualStyle.Office2007
        End With


        If (dt.Rows.Count > 0) Then
            grProducto.Row = 0
        End If
    End Sub

    Private Sub _prCargarDescuentos(ProductoId As Integer)
        Dim dt As New DataTable
        dt = L_fnListarDescuentos(ProductoId)
        grdetalle.DataSource = dt
        grdetalle.RetrieveStructure()
        grdetalle.AlternatingColors = True


        With grdetalle.RootTable.Columns("id")
            .Width = 100
            .Visible = False
        End With
        With grdetalle.RootTable.Columns("ProductoId")
            .Width = 100
            .Visible = False
        End With
        With grdetalle.RootTable.Columns("Productos")
            .Width = 100
            .Visible = False
        End With

        With grdetalle.RootTable.Columns("CantidadInicial")
            .Caption = "Desde"
            .Width = 100
            .Visible = True
            .FormatString = "0"
        End With


        With grdetalle.RootTable.Columns("CantidadFinal")
            .Caption = "Hasta"
            .Width = 100
            .Visible = True
            .FormatString = "0"
        End With

        With grdetalle.RootTable.Columns("Precio")
            .Caption = "Precio"
            .Width = 100
            .Visible = True
            .FormatString = "0.00"
        End With



        With grdetalle.RootTable.Columns("FechaDesde")
            .Width = 90
            .Visible = False
        End With
        With grdetalle.RootTable.Columns("FechaHasta")
            .Width = 90
            .Visible = False
        End With
        With grdetalle.RootTable.Columns("Estado")
            .Width = 90
            .Visible = False
        End With
        With grdetalle
            .GroupByBoxVisible = False
            'diseño de la grilla
            .VisualStyle = VisualStyle.Office2007
        End With



    End Sub

    Private Sub grProducto_SelectionChanged(sender As Object, e As EventArgs) Handles grProducto.SelectionChanged
        If (grProducto.Row >= 0) Then

            lbProducto.Text = grProducto.GetValue("NombreProducto")
            _prCargarDescuentos(grProducto.GetValue("ProductoId"))

        End If
    End Sub

    Private Sub btnNuevo_Click(sender As Object, e As EventArgs) Handles btnNuevo.Click
        tbDesde.IsInputReadOnly = False
        tbHasta.IsInputReadOnly = False
        tbPrecio.IsInputReadOnly = False


        tbDesde.Value = 0
        tbHasta.Value = 0
        tbPrecio.Value = 0
        tbDesde.Focus()

        btnNuevo.Visible = False
        btnGrabar.Visible = True

    End Sub
    Public Function _ValidarCampos() As Boolean
        If (grProducto.Row < 0) Then
            Dim img As Bitmap = New Bitmap(My.Resources.mensaje, 50, 50)
            ToastNotification.Show(Me, "Por Favor debe dar click a un producto".ToUpper, img, 2000, eToastGlowColor.Red, eToastPosition.BottomCenter)
            Return False
        End If


        If tbDesde.Value.ToString = String.Empty Or tbHasta.Value.ToString = String.Empty Or tbPrecio.Value.ToString = String.Empty Then
            Dim img As Bitmap = New Bitmap(My.Resources.mensaje, 50, 50)
            ToastNotification.Show(Me, "Los campos no pueden estar vacios por favor coloque datos mayores a 0".ToUpper, img, 4000, eToastGlowColor.Red, eToastPosition.BottomCenter)
            Return False
        Else
            If (tbDesde.Value <= 0 Or tbHasta.Value <= 0 Or tbPrecio.Value <= 0) Then
                Dim img As Bitmap = New Bitmap(My.Resources.mensaje, 50, 50)
                ToastNotification.Show(Me, "Las campos no pueden ser 0 por favor coloque datos mayores a 0".ToUpper, img, 4000, eToastGlowColor.Red, eToastPosition.BottomCenter)
                Return False
            End If
        End If


        Return True
    End Function

    Private Sub btnGrabar_Click(sender As Object, e As EventArgs) Handles btnGrabar.Click
        Dim numi As String = ""
        If (_ValidarCampos()) Then
            'Grabar
            Dim res As Boolean = L_fnGrabarPreciosDescuentos(numi, grProducto.GetValue("ProductoId"), tbDesde.Value, tbHasta.Value, tbPrecio.Value)

            If (res) Then
                ToastNotification.Show(Me, "Descuento de Producto Grabado con éxito.".ToUpper,
                                   My.Resources.GRABACION_EXITOSA,
                                   3000,
                                   eToastGlowColor.Green,
                                   eToastPosition.TopCenter)




                btnNuevo.Visible = True
                btnGrabar.Visible = False

                tbDesde.Value = 0
                tbHasta.Value = 0
                tbPrecio.Value = 0

                _prCargarDescuentos(grProducto.GetValue("ProductoId"))

            Else
                ToastNotification.Show(Me, "No se pudo grabar los descuentos.".ToUpper,
                                   My.Resources.WARNING,
                                   3000,
                                   eToastGlowColor.Red,
                                   eToastPosition.TopCenter)
            End If
        End If
    End Sub

    Private Sub ButtonX1_Click(sender As Object, e As EventArgs) Handles ButtonX1.Click
        Me.Close()

    End Sub
End Class