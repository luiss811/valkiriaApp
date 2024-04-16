// Ruta para obtener la lista de deseos por usuario
app.get('/wishlist', verifyToken, (req, res) => {
    const usuario = req.usuario.usuario;
    console.log(usuario);

    const query = `
      SELECT lista_deseos.id_lista, producto.*, sucursal.nom_suc, inventario.exist_prod, inventario.id_inv, inventario.estatus_inv
      FROM lista_deseos
      JOIN inventario ON lista_deseos.id_inv = inventario.id_inv
      JOIN producto ON inventario.id_prod = producto.id_prod
      JOIN sucursal ON inventario.id_suc = sucursal.id_suc
      WHERE lista_deseos.usuario = ? AND inventario.estatus_inv = 1
    `;

    connection.query(query, [usuario], (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).json({ success: false, message: 'Internal server error' });
        } else {
            if (result.length > 0) {
                const wishlistArray = result.map((row) => ({
                    wishlistId: row.id_lista,
                    inventoryId: row.id_inv,
                    stock: row.exist_prod,
                    inventoryStatus: row.estatus_inv,
                    name: row.nom_prod,
                    imagePath: row.img_prod,
                    branch: row.nom_suc,
                    price: row.prec_prod,
                }));
                console.log("Productos de la lista de deseos:");
                console.log(wishlistArray);
                res.json(wishlistArray);
            } else {
                res.json({ message: 'No tienes productos en tu lista de deseos' });
            }
        }
    });
});

// Ruta para agregar un producto a la lista de deseos
app.post('/addToWishlist', verifyToken, (req, res) => {
    const usuario = req.usuario.usuario;
    const inventoryId = req.body.id_inv;

    // Verificar si el usuario ya tiene el producto en su lista de deseos
    const checkQuery = 'SELECT * FROM lista_deseos WHERE usuario = ? AND id_inv = ?';
    connection.query(checkQuery, [usuario, inventoryId], (err, result) => {
        if (result.length > 0) {
            // El producto ya está en la lista de deseos del usuario
            return res.json({ success: false, message: 'El producto ya está en tu lista de deseos' });
        } else {
            // Agregar el producto a la lista de deseos
            const insertQuery = 'INSERT INTO lista_deseos (usuario, id_inv) VALUES (?, ?)';
            connection.query(insertQuery, [usuario, inventoryId], (err, result) => {
                return res.json({ success: true, message: 'Producto agregado a tu lista de deseos' });
            });
        }
    });
});

// Eliminar producto de la lista de deseos
app.post('/removeFromWishlist', verifyToken, (req, res) => {
    const { id_lista } = req.body;

    const sql = `DELETE FROM lista_deseos WHERE id_lista = ?`;
    connection.query(sql, [id_lista], (err, result) => {
        res.json({ success: true, message: 'Producto eliminado de la lista de deseos correctamente' });
    });
});

// Ruta para obtener los productos del carrito por usuario
app.get('/cart', verifyToken, (req, res) => {
    const usuario = req.usuario.usuario;

    const query = `
      SELECT carrito.id_carrito, inventario.*, producto.*, sucursal.nom_suc, carrito.cant_prod
      FROM carrito
      JOIN inventario ON carrito.id_inv = inventario.id_inv
      JOIN producto ON inventario.id_prod = producto.id_prod
      JOIN sucursal ON inventario.id_suc = sucursal.id_suc
      WHERE carrito.usuario = ? AND inventario.estatus_inv = 1 AND inventario.exist_prod > 0
    `;

    connection.query(query, [usuario], (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).json({ success: false, message: 'Error interno del servidor' });
        } else {
            if (result.length > 0) {
                const cartArray = result.map((row) => ({
                    cartId: row.id_carrito,
                    inventoryId: row.id_inv,
                    stock: row.exist_prod,
                    quantity: row.cant_prod,
                    inventoryStatus: row.estatus_inv,
                    name: row.nom_prod,
                    imagePath: row.img_prod,
                    branch: row.nom_suc,
                    price: row.prec_prod,
                    cost: row.cto_prod,
                }));
                console.log("Productos del carrito:");
                console.log(cartArray);
                res.json(cartArray);
            } else {
                res.json({ message: 'No tienes productos en tu carrito' });
            }
        }
    });
});

// Ruta para agregar un producto al carrito
app.post('/addToCart', verifyToken, (req, res) => {
    const usuario = req.usuario.usuario;
    const inventoryId = req.body.id_inv;

    const checkStockQuery = 'SELECT exist_prod FROM inventario WHERE id_inv = ?';
    connection.query(checkStockQuery, [inventoryId], (err, result) => {

        if (result.length === 0 || result[0].exist_prod === 0) {
            return res.json({ success: false, message: 'El producto no está disponible en existencia' });
        } else {
            const checkCartQuery = 'SELECT * FROM carrito WHERE usuario = ? AND id_inv = ?';
            connection.query(checkCartQuery, [usuario, inventoryId], (err, result) => {

                if (result.length > 0) {
                    return res.json({ success: false, message: 'El producto ya está en tu carrito' });
                } else {
                    const insertQuery = 'INSERT INTO carrito (usuario, id_inv, cant_prod) VALUES (?, ?, 1)';
                    connection.query(insertQuery, [usuario, inventoryId], (err, result) => {
                        return res.json({ success: true, message: 'Producto agregado a tu carrito' });
                    });
                }
            });
        }
    });
});

// Ruta PUT para actualizar la cantidad de productos en el carrito
app.put('/updateCart/:idCarrito', verifyToken, (req, res) => {
    const idCarrito = req.params.idCarrito;
    const nuevaCantidad = req.body.cantidad;

    const query = 'UPDATE carrito SET cant_prod = ? WHERE id_carrito = ?';
    connection.query(query, [nuevaCantidad, idCarrito], (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Error al actualizar la cantidad');
        } else {
            res.status(200).send('Cantidad actualizada correctamente');
        }
    });
});

// Eliminar producto del carrito
app.post('/removeFromCart', verifyToken, (req, res) => {
    const { id_carrito } = req.body;

    const sql = `DELETE FROM carrito WHERE id_carrito = ?`;
    connection.query(sql, [id_carrito], (err, result) => {
        res.json({ success: true, message: 'Producto eliminado del carrito correctamente' });
    });
});

// Ruta para obtener los datos de un cliente por su nombre de usuario
app.get('/userData', verifyToken, (req, res) => {
    const usuario = req.usuario.usuario;

    const query = `
      SELECT *
      FROM cliente
      WHERE nom_us = ?
    `;

    connection.query(query, [usuario], (err, result) => {
        if (result.length > 0) {
            const clientData = result[0];
            console.log("Datos del cliente:");
            console.log(clientData);
            res.json(clientData);
        } else {
            res.status(404).json({ message: 'Cliente no encontrado' });
        }
    });
});

app.put('/actualizarPerfil', verifyToken, async (req, res) => {
    const { numero_cliente, nombre, apellido, apellidoMaterno, email, telefono } = req.body;

    // Verificar si el nuevo correo electrónico ya existe en la base de datos
    const checkEmailQuery = 'SELECT * FROM cliente WHERE email_clie = ? AND no_clie != ?';
    connection.query(checkEmailQuery, [email, numero_cliente], (err, results) => {
        if (results.length > 0) {
            // El correo electrónico ya existe en la base de datos
            return res.status(400).json({ success: false, message: 'El correo electrónico ya está en uso' });
        } else {
            // El correo electrónico es único, proceder con la actualización
            const sql = `UPDATE cliente SET n1_clie=?, ap_clie=?, am_clie=?, email_clie=?, tel_clie=? WHERE no_clie=?`;
            connection.query(sql, [nombre, apellido, apellidoMaterno, email, telefono, numero_cliente], (err, result) => {
                console.log("Detalles de usuario actualizados correctamente");
                res.status(200).json({ success: true, message: 'Detalles de usuario actualizados correctamente' });
            });
        }
    });
});

// Ruta para actualizar la dirección de un cliente
app.put('/actualizarDireccion', verifyToken, (req, res) => {
    const { numero_cliente, colonia, calle, numExt, numInt, codigoPostal } = req.body;

    // Actualizar la dirección del cliente
    const updateQuery = 'UPDATE cliente SET col_clie = ?, call_clie = ?, ne_clie = ?, ni_clie = ?, cp_clie = ? WHERE no_clie = ?';
    connection.query(updateQuery, [colonia, calle, numExt, numInt, codigoPostal, numero_cliente], (err, result) => {
        if (err) throw err;
        res.send('Dirección actualizada correctamente');
    });
});

app.get('/verificar-datos-cliente', verifyToken, (req, res) => {
    const usuario = req.usuario.usuario;

    const query = `
      SELECT c.email_clie, c.tel_clie, c.n1_clie, c.ap_clie, c.am_clie, c.col_clie, c.call_clie, c.ne_clie, c.cp_clie
      FROM cliente c
      JOIN usuario u ON c.nom_us = u.usuario
      WHERE u.usuario = ?
    `;

    connection.query(query, [usuario], (error, results) => {

        const cliente = results[0];

        // Verificar si faltan datos del cliente
        const tieneEmailYTelefono = cliente.email_clie && cliente.tel_clie;
        const tieneNombreCompleto = cliente.n1_clie && cliente.ap_clie;

        // Verificar si faltan datos de dirección
        const tieneDireccionCompleta = cliente.col_clie && cliente.call_clie && cliente.ne_clie && cliente.cp_clie;

        if (tieneEmailYTelefono && tieneNombreCompleto && tieneDireccionCompleta) {
            return res.status(200).json({ mensaje: 'El cliente tiene todos los datos requeridos' });
        } else if (!tieneEmailYTelefono || !tieneNombreCompleto) {
            return res.status(400).json({ error: 'Faltan datos del cliente' });
        } else if (!tieneDireccionCompleta) {
            return res.status(400).json({ error: 'Faltan datos de la dirección' });
        }
    });
});

app.post('/realizar-venta', verifyToken, (req, res) => {
    const usuario = req.usuario.usuario;
    const { total, paymentMethod } = req.body;

    // Obtener no_clie de usuario
    const queryCliente = 'SELECT c.no_clie FROM cliente c WHERE c.nom_us = ?';
    connection.query(queryCliente, [usuario], (errorCliente, resultsCliente) => {

        const noCliente = resultsCliente[0].no_clie;

        // Insertar venta y obtener el no_vta
        const queryVenta = 'INSERT INTO venta (no_clie) VALUES (?)';
        connection.query(queryVenta, [noCliente], (errorVenta, resultsVenta) => {

            const noVenta = resultsVenta.insertId;

            // Insertar ven_inv con los productos del carrito del usuario
            const queryCarrito = 'SELECT id_inv, cant_prod FROM carrito WHERE usuario = ?';
            connection.query(queryCarrito, [usuario], (errorCarrito, resultsCarrito) => {

                const insertVenInv = 'INSERT INTO ven_inv (no_vta, id_inv, cant_prod) VALUES ?';
                const valuesVenInv = resultsCarrito.map(({ id_inv, cant_prod }) => [noVenta, id_inv, cant_prod]);

                connection.query(insertVenInv, [valuesVenInv], (errorVenInv, resultsVenInv) => {

                    // Eliminar productos del carrito del usuario
                    const deleteCarrito = 'DELETE FROM carrito WHERE usuario = ?';
                    connection.query(deleteCarrito, [usuario], (errorDelete, resultsDelete) => {

                        return res.status(200).json({ mensaje: 'Venta realizada con éxito' });
                    });
                });
            });
        });
    });
});

// Ruta para obtener el historial de compras del usuario
app.get('/shopping-history', verifyToken, (req, res) => {
    const usuario = req.usuario.usuario;

    const query = `
      SELECT v.fec_vta, p.nom_prod, p.img_prod, p.prec_prod, vi.cant_prod, s.nom_suc
      FROM venta v
      JOIN ven_inv vi ON v.no_vta = vi.no_vta
      JOIN inventario i ON vi.id_inv = i.id_inv
      JOIN producto p ON i.id_prod = p.id_prod
      JOIN cliente c ON v.no_clie = c.no_clie
      JOIN usuario u ON c.nom_us = u.usuario
      JOIN sucursal s ON i.id_suc = s.id_suc
      WHERE u.usuario = ?
      ORDER BY v.fec_vta DESC, v.no_vta DESC`;

    connection.query(query, [usuario], (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).json({ success: false, message: 'Error interno del servidor' });
        } else {
            if (result.length > 0) {
                const array = result.map((row) => ({
                    quantityPurchased: row.cant_prod,
                    name: row.nom_prod,
                    imagePath: row.img_prod,
                    branch: row.nom_suc,
                    purchaseDate: new Date(row.fec_vta).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
                    price: row.prec_prod,
                }));
                res.json(array);
            } else {
                res.json({ message: 'El historial de compras está vacío' });
            }
        }
    });
});
