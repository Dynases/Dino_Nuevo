﻿<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class F_Cantidad
    Inherits System.Windows.Forms.Form

    'Form reemplaza a Dispose para limpiar la lista de componentes.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Requerido por el Diseñador de Windows Forms
    Private components As System.ComponentModel.IContainer

    'NOTA: el Diseñador de Windows Forms necesita el siguiente procedimiento
    'Se puede modificar usando el Diseñador de Windows Forms.  
    'No lo modifique con el editor de código.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.Panel1 = New System.Windows.Forms.Panel()
        Me.ReflectionLabel1 = New DevComponents.DotNetBar.Controls.ReflectionLabel()
        Me.lbProducto = New System.Windows.Forms.Label()
        Me.lbStock = New System.Windows.Forms.Label()
        Me.tbCantidad = New DevComponents.Editors.DoubleInput()
        Me.lbConversion = New System.Windows.Forms.Label()
        Me.tbConversion = New DevComponents.Editors.DoubleInput()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.Panel1.SuspendLayout()
        CType(Me.tbCantidad, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.tbConversion, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'Panel1
        '
        Me.Panel1.BackgroundImage = Global.DinoM.My.Resources.Resources.fondo1
        Me.Panel1.Controls.Add(Me.ReflectionLabel1)
        Me.Panel1.Dock = System.Windows.Forms.DockStyle.Top
        Me.Panel1.Location = New System.Drawing.Point(0, 0)
        Me.Panel1.Margin = New System.Windows.Forms.Padding(2, 2, 2, 2)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(520, 55)
        Me.Panel1.TabIndex = 0
        '
        'ReflectionLabel1
        '
        Me.ReflectionLabel1.BackColor = System.Drawing.Color.Transparent
        '
        '
        '
        Me.ReflectionLabel1.BackgroundStyle.CornerType = DevComponents.DotNetBar.eCornerType.Square
        Me.ReflectionLabel1.Font = New System.Drawing.Font("Calibri", 16.2!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.ReflectionLabel1.ForeColor = System.Drawing.Color.White
        Me.ReflectionLabel1.Location = New System.Drawing.Point(9, 10)
        Me.ReflectionLabel1.Margin = New System.Windows.Forms.Padding(2, 2, 2, 2)
        Me.ReflectionLabel1.Name = "ReflectionLabel1"
        Me.ReflectionLabel1.Size = New System.Drawing.Size(278, 43)
        Me.ReflectionLabel1.TabIndex = 0
        Me.ReflectionLabel1.Text = "Cantidad Del Producto"
        '
        'lbProducto
        '
        Me.lbProducto.Font = New System.Drawing.Font("Calibri", 18.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lbProducto.ForeColor = System.Drawing.Color.Navy
        Me.lbProducto.Location = New System.Drawing.Point(11, 58)
        Me.lbProducto.Margin = New System.Windows.Forms.Padding(2, 0, 2, 0)
        Me.lbProducto.Name = "lbProducto"
        Me.lbProducto.Size = New System.Drawing.Size(498, 76)
        Me.lbProducto.TabIndex = 1
        Me.lbProducto.Text = "Producto A"
        Me.lbProducto.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'lbStock
        '
        Me.lbStock.BackColor = System.Drawing.Color.Black
        Me.lbStock.Font = New System.Drawing.Font("Calibri", 12.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lbStock.ForeColor = System.Drawing.Color.White
        Me.lbStock.Location = New System.Drawing.Point(104, 133)
        Me.lbStock.Margin = New System.Windows.Forms.Padding(2, 0, 2, 0)
        Me.lbStock.Name = "lbStock"
        Me.lbStock.Size = New System.Drawing.Size(327, 28)
        Me.lbStock.TabIndex = 2
        Me.lbStock.Text = "Stock Disponible = 52.00"
        Me.lbStock.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'tbCantidad
        '
        '
        '
        '
        Me.tbCantidad.BackgroundStyle.Class = "DateTimeInputBackground"
        Me.tbCantidad.BackgroundStyle.CornerType = DevComponents.DotNetBar.eCornerType.Square
        Me.tbCantidad.ButtonFreeText.Shortcut = DevComponents.DotNetBar.eShortcut.F2
        Me.tbCantidad.Font = New System.Drawing.Font("Calibri", 25.8!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.tbCantidad.Increment = 1.0R
        Me.tbCantidad.Location = New System.Drawing.Point(160, 205)
        Me.tbCantidad.Margin = New System.Windows.Forms.Padding(2, 2, 2, 2)
        Me.tbCantidad.Name = "tbCantidad"
        Me.tbCantidad.Size = New System.Drawing.Size(227, 49)
        Me.tbCantidad.TabIndex = 0
        '
        'lbConversion
        '
        Me.lbConversion.BackColor = System.Drawing.Color.Black
        Me.lbConversion.Font = New System.Drawing.Font("Calibri", 12.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lbConversion.ForeColor = System.Drawing.Color.White
        Me.lbConversion.Location = New System.Drawing.Point(179, 164)
        Me.lbConversion.Margin = New System.Windows.Forms.Padding(2, 0, 2, 0)
        Me.lbConversion.Name = "lbConversion"
        Me.lbConversion.Size = New System.Drawing.Size(95, 25)
        Me.lbConversion.TabIndex = 3
        Me.lbConversion.Text = "Conversión:"
        Me.lbConversion.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'tbConversion
        '
        '
        '
        '
        Me.tbConversion.BackgroundStyle.BackColor = System.Drawing.Color.Black
        Me.tbConversion.BackgroundStyle.Class = "DateTimeInputBackground"
        Me.tbConversion.BackgroundStyle.CornerType = DevComponents.DotNetBar.eCornerType.Square
        Me.tbConversion.ButtonFreeText.Shortcut = DevComponents.DotNetBar.eShortcut.F2
        Me.tbConversion.Font = New System.Drawing.Font("Calibri", 12.0!)
        Me.tbConversion.ForeColor = System.Drawing.Color.White
        Me.tbConversion.Increment = 1.0R
        Me.tbConversion.IsInputReadOnly = True
        Me.tbConversion.Location = New System.Drawing.Point(276, 164)
        Me.tbConversion.MinValue = 0R
        Me.tbConversion.Name = "tbConversion"
        Me.tbConversion.Size = New System.Drawing.Size(95, 27)
        Me.tbConversion.TabIndex = 4
        Me.tbConversion.WatermarkAlignment = DevComponents.Editors.eTextAlignment.Right
        '
        'Label1
        '
        Me.Label1.Font = New System.Drawing.Font("Calibri", 14.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label1.Location = New System.Drawing.Point(24, 216)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(130, 28)
        Me.Label1.TabIndex = 5
        Me.Label1.Text = "Cant.Unidades:" & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10)
        '
        'F_Cantidad
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.BackColor = System.Drawing.Color.White
        Me.ClientSize = New System.Drawing.Size(520, 281)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.tbConversion)
        Me.Controls.Add(Me.lbConversion)
        Me.Controls.Add(Me.tbCantidad)
        Me.Controls.Add(Me.lbStock)
        Me.Controls.Add(Me.lbProducto)
        Me.Controls.Add(Me.Panel1)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None
        Me.Margin = New System.Windows.Forms.Padding(2, 2, 2, 2)
        Me.Name = "F_Cantidad"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.Text = "F_Cantidad"
        Me.Panel1.ResumeLayout(False)
        CType(Me.tbCantidad, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.tbConversion, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)

    End Sub

    Friend WithEvents Panel1 As Panel
    Friend WithEvents lbProducto As Label
    Friend WithEvents lbStock As Label
    Friend WithEvents tbCantidad As DevComponents.Editors.DoubleInput
    Friend WithEvents ReflectionLabel1 As DevComponents.DotNetBar.Controls.ReflectionLabel
    Friend WithEvents lbConversion As Label
    Public WithEvents tbConversion As DevComponents.Editors.DoubleInput
    Friend WithEvents Label1 As Label
End Class
