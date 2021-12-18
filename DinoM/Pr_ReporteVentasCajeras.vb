Imports Logica.AccesoLogica
Imports DevComponents.DotNetBar
Public Class Pr_ReporteVentasCajeras

    Dim _Inter As Integer = 0

    Public _nameButton As String
    Public _tab As SuperTabItem
    Public Sub _prIniciarTodo()
        tbFechaI.Value = Now.Date
        tbFechaF.Value = Now.Date
        _PMIniciarTodo()

        Me.Text = "REPORTE VENTAS POR CAJERA"
        MReportViewer.ToolPanelView = CrystalDecisions.Windows.Forms.ToolPanelViewType.None
        _IniciarComponentes()
    End Sub
    Public Sub _IniciarComponentes()
        tbVendedor.ReadOnly = True
        tbAlmacen.ReadOnly = True
        tbVendedor.Enabled = False
        tbAlmacen.Enabled = False
        CheckTodosVendedor.CheckValue = True
        CheckTodosAlmacen.CheckValue = True
        ckTodosProveedor.CheckValue = True
        If (gb_FacturaIncluirICE) Then
            'swIce.Visible = True
        Else
            'swIce.Visible = False
        End If

    End Sub
    Public Function _prValidadrFiltros() As DataTable

        Dim fechaDesde As DateTime = tbFechaI.Value.ToString("yyyy/MM/dd")
        Dim fechaHasta As DateTime = tbFechaF.Value.ToString("yyyy/MM/dd")
        Dim idVendedor As Integer = 0
        Dim idProveedor As Integer = 0
        Dim idAlmacen As Integer = 0
        If CheckTodosAlmacen.Checked = False And CheckUnaALmacen.Checked = True And tbCodAlmacen.Text <> String.Empty Then
            idAlmacen = tbCodAlmacen.Text
        End If
        If CheckTodosVendedor.Checked = False And checkUnaVendedor.Checked = True And tbCodigoVendedor.Text <> String.Empty Then
            idVendedor = tbCodigoVendedor.Text
        End If
        If ckTodosProveedor.Checked = False And ckUnoProveedor.Checked = True And tbCodigoProveedor.Text <> String.Empty Then
            idProveedor = tbCodigoProveedor.Text
        End If

        'Obtiene las ventas con y sin factura
        Dim ventasAtendidas As DataTable = L_BuscarVentasAtentidas(fechaDesde, fechaHasta, idAlmacen, idVendedor, idProveedor)
        Return ventasAtendidas

    End Function
    Private Sub _prCargarReporte()
        Dim _ventasAtendidas As New DataTable
        _ventasAtendidas = _prValidadrFiltros()
        If (_ventasAtendidas.Rows.Count > 0) Then
            Dim objrep As New R_VentasAtendidasAlmacenVendedor
            objrep.SetDataSource(_ventasAtendidas)
            Dim fechaI As String = tbFechaI.Value.ToString("dd/MM/yyyy")
            Dim fechaF As String = tbFechaF.Value.ToString("dd/MM/yyyy")
            objrep.SetParameterValue("usuario", L_Usuario)
            objrep.SetParameterValue("fechaI", fechaI)
            objrep.SetParameterValue("fechaF", fechaF)
            MReportViewer.ReportSource = objrep
            MReportViewer.Show()
            MReportViewer.BringToFront()

            'If (swTipoVenta.Value = True) Then
            '    Dim objrep As New R_VentasAtendidasAlmacenVendedor
            '    objrep.SetDataSource(_ventasAtendidas)
            '    Dim fechaI As String = tbFechaI.Value.ToString("dd/MM/yyyy")
            '    Dim fechaF As String = tbFechaF.Value.ToString("dd/MM/yyyy")
            '    objrep.SetParameterValue("usuario", L_Usuario)
            '    objrep.SetParameterValue("fechaI", fechaI)
            '    objrep.SetParameterValue("fechaF", fechaF)
            '    MReportViewer.ReportSource = objrep
            '    MReportViewer.Show()
            '    MReportViewer.BringToFront()
            'Else
            '    Dim objrep As New R_VentasAtendidasVendedorAlmacen
            '    objrep.SetDataSource(_ventasAtendidas)
            '    Dim fechaI As String = tbFechaI.Value.ToString("dd/MM/yyyy")
            '    Dim fechaF As String = tbFechaF.Value.ToString("dd/MM/yyyy")
            '    objrep.SetParameterValue("usuario", L_Usuario)
            '    objrep.SetParameterValue("fechaI", fechaI)
            '    objrep.SetParameterValue("fechaF", fechaF)
            '    MReportViewer.ReportSource = objrep
            '    MReportViewer.Show()
            '    MReportViewer.BringToFront()
            'End If

        Else
            ToastNotification.Show(Me, "NO HAY DATOS PARA LOS PARAMETROS SELECCIONADOS..!!!",
                                       My.Resources.INFORMATION, 2000,
                                       eToastGlowColor.Blue,
                                       eToastPosition.BottomLeft)
            MReportViewer.ReportSource = Nothing
        End If
    End Sub
    Private Sub btnGenerar_Click(sender As Object, e As EventArgs) Handles btnGenerar.Click
        _prCargarReporte()
    End Sub

    Private Sub Pr_VentasCajeras_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        _prIniciarTodo()
    End Sub
    Private Sub checkUnaVendedor_CheckValueChanged(sender As Object, e As EventArgs) Handles checkUnaVendedor.CheckValueChanged
        If (checkUnaVendedor.Checked) Then
            CheckTodosVendedor.CheckValue = False
            tbVendedor.Enabled = True
            tbVendedor.BackColor = Color.White
            tbVendedor.Focus()
        End If
    End Sub

    Private Sub CheckTodosVendedor_CheckValueChanged(sender As Object, e As EventArgs) Handles CheckTodosVendedor.CheckValueChanged
        If (CheckTodosVendedor.Checked) Then
            checkUnaVendedor.CheckValue = False
            tbVendedor.Enabled = True
            tbVendedor.BackColor = Color.Gainsboro
            tbVendedor.Clear()
            tbCodigoVendedor.Clear()
        End If
    End Sub

    Private Sub CheckUnaALmacen_CheckValueChanged(sender As Object, e As EventArgs) Handles CheckUnaALmacen.CheckValueChanged
        If (CheckUnaALmacen.Checked) Then
            CheckTodosAlmacen.CheckValue = False
            tbAlmacen.Enabled = True
            tbAlmacen.BackColor = Color.White
            tbAlmacen.Focus()
            tbAlmacen.ReadOnly = False
            _prCargarComboLibreriaSucursal(tbAlmacen)
            If (CType(tbAlmacen.DataSource, DataTable).Rows.Count > 0) Then
                tbAlmacen.SelectedIndex = 0
            End If
        End If
    End Sub

    Private Sub ckTodosCliente_CheckValueChanged(sender As Object, e As EventArgs) Handles ckTodosProveedor.CheckValueChanged
        If (ckTodosProveedor.Checked) Then
            ckUnoProveedor.CheckValue = False
            tbProveedor.Enabled = True
            tbProveedor.BackColor = Color.Gainsboro
            tbProveedor.Clear()
            tbCodigoProveedor.Clear()
        End If
    End Sub

    Private Sub ckUnoCliente_CheckedChanged(sender As Object, e As EventArgs) Handles ckUnoProveedor.CheckedChanged
        If (ckUnoProveedor.Checked) Then
            ckTodosProveedor.CheckValue = False
            tbProveedor.Enabled = True
            tbProveedor.BackColor = Color.White
            tbProveedor.Focus()
        End If
    End Sub
    Private Sub CheckTodosAlmacen_CheckValueChanged(sender As Object, e As EventArgs) Handles CheckTodosAlmacen.CheckValueChanged
        If (CheckTodosAlmacen.Checked) Then
            CheckUnaALmacen.CheckValue = False
            tbAlmacen.Enabled = True
            tbAlmacen.BackColor = Color.Gainsboro
            tbAlmacen.ReadOnly = True
            _prCargarComboLibreriaSucursal(tbAlmacen)
            CType(tbAlmacen.DataSource, DataTable).Rows.Clear()
            tbAlmacen.SelectedIndex = -1

        End If
    End Sub

    Private Sub _prCargarComboLibreriaSucursal(mCombo As Janus.Windows.GridEX.EditControls.MultiColumnCombo)
        Dim dt As New DataTable
        dt = L_fnListarSucursales()
        With mCombo
            .DropDownList.Columns.Clear()
            .DropDownList.Columns.Add("aanumi").Width = 60
            .DropDownList.Columns("aanumi").Caption = "COD"
            .DropDownList.Columns.Add("aabdes").Width = 500
            .DropDownList.Columns("aabdes").Caption = "SUCURSAL"
            .ValueMember = "aanumi"
            .DisplayMember = "aabdes"
            .DataSource = dt
            .Refresh()
        End With
    End Sub

    Private Sub tbVendedor_KeyDown_1(sender As Object, e As KeyEventArgs) Handles tbVendedor.KeyDown
        If (checkUnaVendedor.Checked) Then
            If e.KeyData = Keys.Control + Keys.Enter Then
                Dim dt As DataTable
                dt = L_fnListarEmpleado()
                '              a.ydnumi, a.ydcod, a.yddesc, a.yddctnum, a.yddirec
                ',a.ydtelf1 ,a.ydfnac 
                Dim listEstCeldas As New List(Of Modelo.Celda)
                listEstCeldas.Add(New Modelo.Celda("ydnumi,", False, "ID", 50))
                listEstCeldas.Add(New Modelo.Celda("ydcod", True, "ID", 50))
                listEstCeldas.Add(New Modelo.Celda("yddesc", True, "NOMBRE", 280))
                listEstCeldas.Add(New Modelo.Celda("yddctnum", True, "N. Documento".ToUpper, 150))
                listEstCeldas.Add(New Modelo.Celda("yddirec", True, "DIRECCION", 220))
                listEstCeldas.Add(New Modelo.Celda("ydtelf1", True, "Telefono".ToUpper, 200))
                listEstCeldas.Add(New Modelo.Celda("ydfnac", True, "F.Nacimiento".ToUpper, 150, "MM/dd,YYYY"))
                Dim ef = New Efecto
                ef.tipo = 3
                ef.dt = dt
                ef.SeleclCol = 1
                ef.listEstCeldas = listEstCeldas
                ef.alto = 50
                ef.ancho = 350
                ef.Context = "Seleccione Vendedor".ToUpper
                ef.ShowDialog()
                Dim bandera As Boolean = False
                bandera = ef.band
                If (bandera = True) Then
                    Dim Row As Janus.Windows.GridEX.GridEXRow = ef.Row
                    If (IsNothing(Row)) Then
                        tbVendedor.Focus()
                        Return
                    End If
                    tbCodigoVendedor.Text = Row.Cells("ydnumi").Value
                    tbVendedor.Text = Row.Cells("yddesc").Value
                    btnGenerar.Focus()
                End If

            End If

        End If
    End Sub

    Private Sub btnSalir_Click(sender As Object, e As EventArgs) Handles btnSalir.Click
        Me.Close()
    End Sub

    Private Sub Timer1_Tick(sender As Object, e As EventArgs) Handles Timer1.Tick
        _Inter = _Inter + 1
        If _Inter = 1 Then
            Me.WindowState = FormWindowState.Normal

        Else
            Me.Opacity = 100
            Timer1.Enabled = False
        End If
    End Sub

    Private Sub tbProveedor_KeyDown(sender As Object, e As KeyEventArgs) Handles tbProveedor.KeyDown
        If (ckUnoProveedor.Checked) Then
            If e.KeyData = Keys.Control + Keys.Enter Then

                Dim dt As DataTable
                dt = L_prLibreriaClienteLGeneral(1, 1)

                Dim listEstCeldas As New List(Of Modelo.Celda)
                listEstCeldas.Add(New Modelo.Celda("yccod3,", True, "CÓDIGO", 70))
                listEstCeldas.Add(New Modelo.Celda("ycdes3", True, "PROVEEDOR", 200))

                Dim ef = New Efecto
                ef.tipo = 3
                ef.dt = dt
                ef.SeleclCol = 2
                ef.listEstCeldas = listEstCeldas
                ef.alto = 50
                ef.ancho = 350
                ef.Context = "Seleccione Proveedor".ToUpper
                ef.ShowDialog()
                Dim bandera As Boolean = False
                bandera = ef.band
                If (bandera = True) Then
                    Dim Row As Janus.Windows.GridEX.GridEXRow = ef.Row
                    tbCodigoProveedor.Text = Row.Cells("yccod3").Value
                    tbProveedor.Text = Row.Cells("ycdes3").Value
                End If
            End If
        End If
    End Sub

    Private Sub tbUsuario_KeyDown(sender As Object, e As KeyEventArgs) Handles tbUsuario.KeyDown
        If (checkUnaVendedor.Checked) Then
            If e.KeyData = Keys.Control + Keys.Enter Then
                Dim dt As DataTable
                dt = L_ListarUsuarios()

                Dim listEstCeldas As New List(Of Modelo.Celda)
                listEstCeldas.Add(New Modelo.Celda("ydnumi,", True, "ID", 50))
                listEstCeldas.Add(New Modelo.Celda("yduser", True, "USUARIO", 150))
                listEstCeldas.Add(New Modelo.Celda("ydrol", False, "IDROL".ToUpper, 150))
                listEstCeldas.Add(New Modelo.Celda("yd_numiVend", False, "IDVENDEDOR", 220))

                Dim ef = New Efecto
                ef.tipo = 3
                ef.dt = dt
                ef.SeleclCol = 1
                ef.listEstCeldas = listEstCeldas
                ef.alto = 50
                ef.ancho = 350
                ef.Context = "Seleccione Usuario".ToUpper
                ef.ShowDialog()
                Dim bandera As Boolean = False
                bandera = ef.band
                If (bandera = True) Then
                    Dim Row As Janus.Windows.GridEX.GridEXRow = ef.Row
                    If (IsNothing(Row)) Then
                        tbUsuario.Focus()
                        Return
                    End If
                    tbCodigoUsuario.Text = Row.Cells("ydnumi").Value
                    tbUsuario.Text = Row.Cells("yduser").Value
                    btnGenerar.Focus()
                End If

            End If

        End If
    End Sub
End Class