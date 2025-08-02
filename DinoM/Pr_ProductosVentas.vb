Imports Logica.AccesoLogica
Imports DevComponents.DotNetBar
Public Class Pr_ProductosVentas
    Dim _Inter As Integer = 0

    'gb_FacturaIncluirICE

    Public _nameButton As String
    Public _tab As SuperTabItem

    Public Sub _prIniciarTodo()
        tbFechaI.Value = Now.Date
        tbFechaF.Value = Now.Date
        _PMIniciarTodo()
        'L_prAbrirConexion(gs_Ip, gs_UsuarioSql, gs_ClaveSql, gs_NombreBD)
        Me.Text = "REPORTE PRODUCTOS"
        MReportViewer.ToolPanelView = CrystalDecisions.Windows.Forms.ToolPanelViewType.None
        _IniciarComponentes()
    End Sub
    Public Sub _IniciarComponentes()
        tbAlmacen.ReadOnly = True
        tbAlmacen.Enabled = False
        CheckTodosAlmacen.CheckValue = True
        cbProvTodos.CheckValue = True
        cbProv.ReadOnly = True
        cbProv.Enabled = False
        CheckBoxX1.Checked = True
    End Sub
    Public Sub _prInterpretarDatos(ByRef _dt As DataTable)
        If (CheckBoxX1.Checked = True) Then
            _dt = L_prVentasVsProductosGeneral(tbFechaI.Value.ToString("yyyy/MM/dd"), tbFechaF.Value.ToString("yyyy/MM/dd"))

        ElseIf (CheckBoxX2.Checked = True) Then

            If (CheckTodosAlmacen.Checked) Then
                _dt = L_prVentasVsProductosTodosALmacenesPrecio(tbFechaI.Value.ToString("yyyy/MM/dd"), tbFechaF.Value.ToString("yyyy/MM/dd"))
            Else
                If (CheckUnaALmacen.Checked And tbAlmacen.SelectedIndex >= 0) Then
                    _dt = L_prVentasVsProductosUnaALmacenesPrecio(tbFechaI.Value.ToString("yyyy/MM/dd"), tbFechaF.Value.ToString("yyyy/MM/dd"), tbAlmacen.Value)
                End If
            End If
        ElseIf CheckBoxX3.Checked = True Then

            _dt = L_prVentasVsProductosxProveedor(tbFechaI.Value.ToString("yyyy/MM/dd"), tbFechaF.Value.ToString("yyyy/MM/dd"), IIf(CheckTodosAlmacen.Checked = True, -1, tbAlmacen.Value), IIf(cbProvTodos.Checked = True, -1, cbProv.Value))
        End If


    End Sub
    Private Sub _prCargarReporte()
        Dim _dt As New DataTable
        _prInterpretarDatos(_dt)
        If (_dt.Rows.Count > 0) Then
            If (CheckBoxX1.Checked = True) Then
                Dim objrep As New R_VentasProductos
                objrep.SetDataSource(_dt)
                Dim fechaI As String = tbFechaI.Value.ToString("dd/MM/yyyy")
                Dim fechaF As String = tbFechaF.Value.ToString("dd/MM/yyyy")
                objrep.SetParameterValue("usuario", L_Usuario)
                objrep.SetParameterValue("fechaI", fechaI)
                objrep.SetParameterValue("fechaF", fechaF)
                MReportViewer.ReportSource = objrep
                MReportViewer.Show()
                MReportViewer.BringToFront()
            ElseIf (CheckBoxX2.Checked = True) Then
                Dim objrep As New R_VentasProductosAgrupado
                objrep.SetDataSource(_dt)
                Dim fechaI As String = tbFechaI.Value.ToString("dd/MM/yyyy")
                Dim fechaF As String = tbFechaF.Value.ToString("dd/MM/yyyy")
                objrep.SetParameterValue("usuario", L_Usuario)
                objrep.SetParameterValue("fechaI", fechaI)
                objrep.SetParameterValue("fechaF", fechaF)
                MReportViewer.ReportSource = objrep
                MReportViewer.Show()
                MReportViewer.BringToFront()
            ElseIf (CheckBoxX3.Checked = True) Then
                Dim objrep As New R_VentasProductosProveedor
                objrep.SetDataSource(_dt)
                Dim fechaI As String = tbFechaI.Value.ToString("dd/MM/yyyy")
                Dim fechaF As String = tbFechaF.Value.ToString("dd/MM/yyyy")
                objrep.SetParameterValue("usuario", L_Usuario)
                objrep.SetParameterValue("fechaI", fechaI)
                objrep.SetParameterValue("fechaF", fechaF)
                MReportViewer.ReportSource = objrep
                MReportViewer.Show()
                MReportViewer.BringToFront()
            End If

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

    Private Sub Pr_VentasAtendidas_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        _prIniciarTodo()

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

    Private Sub _prCargarComboProveedores(mCombo As Janus.Windows.GridEX.EditControls.MultiColumnCombo)
        Dim dt As New DataTable
        dt = L_fnListarProveedores2()
        With mCombo
            .DropDownList.Columns.Clear()
            .DropDownList.Columns.Add("yccod3").Width = 60
            .DropDownList.Columns("yccod3").Caption = "COD"
            .DropDownList.Columns.Add("ycdes3").Width = 500
            .DropDownList.Columns("ycdes3").Caption = "PROVEEDOR"
            .ValueMember = "yccod3"
            .DisplayMember = "ycdes3"
            .DataSource = dt
            .Refresh()
        End With
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

    Private Sub cbProvTodos_CheckedChanged(sender As Object, e As EventArgs) Handles cbProvTodos.CheckedChanged
        If (cbProvTodos.Checked) Then
            cbProvUna.CheckValue = False
            cbProv.Enabled = True
            cbProv.BackColor = Color.Gainsboro
            cbProv.ReadOnly = True
            _prCargarComboProveedores(cbProv)
            CType(cbProv.DataSource, DataTable).Rows.Clear()
            cbProv.SelectedIndex = -1

        End If
    End Sub

    Private Sub cbProvUna_CheckedChanged(sender As Object, e As EventArgs) Handles cbProvUna.CheckedChanged
        If (cbProvUna.Checked) Then
            cbProvTodos.CheckValue = False
            cbProv.Enabled = True
            cbProv.BackColor = Color.White
            cbProv.Focus()
            cbProv.ReadOnly = False
            _prCargarComboProveedores(cbProv)
            If (CType(cbProv.DataSource, DataTable).Rows.Count > 0) Then
                cbProv.SelectedIndex = 0

            End If
        End If
    End Sub

    Private Sub CheckBoxX3_CheckedChanged(sender As Object, e As EventArgs) Handles CheckBoxX3.CheckedChanged
        If CheckBoxX3.Checked = True Then
            lbProveedor.Visible = True
            'tbCodProv.Visible = True
            cbProv.Visible = True
            cbProvTodos.Visible = True
            cbProvUna.Visible = True

        End If
    End Sub

    Private Sub CheckBoxX1_CheckedChanged(sender As Object, e As EventArgs) Handles CheckBoxX1.CheckedChanged
        If CheckBoxX1.Checked = True Then
            lbProveedor.Visible = False
            tbCodProv.Visible = False
            cbProv.Visible = False
            cbProvTodos.Visible = False
            cbProvUna.Visible = False
        End If
    End Sub

    Private Sub CheckBoxX2_CheckedChanged(sender As Object, e As EventArgs) Handles CheckBoxX2.CheckedChanged
        If CheckBoxX2.Checked = True Then
            lbProveedor.Visible = False
            tbCodProv.Visible = False
            cbProv.Visible = False
            cbProvTodos.Visible = False
            cbProvUna.Visible = False
        End If
    End Sub
End Class